From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6412] New: Kernel crashes randomly -- Unable
 to handle kernel NULL pointer dereference ...
Date: Wed, 19 Apr 2006 13:48:46 -0700
Message-ID: <20060419134846.0f858bf2.akpm@osdl.org>
References: <200604192034.k3JKYpxD007463@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: webmatt000@arcor.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39839 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751219AbWDSUqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 16:46:25 -0400
To: bugme-daemon@bugzilla.kernel.org
In-Reply-To: <200604192034.k3JKYpxD007463@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6412
> 
>            Summary: Kernel crashes randomly -- Unable to handle kernel NULL
>                     pointer dereference ...
>     Kernel Version: 2.6.16.5 - mainline, neither out of tree modules loaded
>                     nor comp
>             Status: NEW
>           Severity: normal
>              Owner: acme@conectiva.com.br
>          Submitter: webmatt000@arcor.de
> 
> 
> Most recent kernel where this bug did not occur:
> Unknown - My SMP machine keeps crashing scince kernel version 2.6.10 or so up to
> 7 times a day. Most of the time I am unable to tell you the cause of the
> crashes, because my syslogs do not contian any data about that.
> 
> Distribution: Debian
> 
> Hardware Environment: SMP, i386,
> 
> Software Environment: root-nfs; SMP disabled in kernel in the hope to reduce the
> number the of kernel crashes; I was running X, KDE 3.5 and Mozilla
> 
> Problem Description:
> Suddenly, my PC  restarted X, started xdm and my screen, mouse and keyboard were
> frozen. I was able to log into the crashed machine from my nfs server via ssh
> and to produce this dmesg:
> 
> IN=wan0 OUT= MAC=ff:ff:ff:ff:ff:ff:00:80:77:48:f6:fa:08:00 SRC=192.168.2.2
> DST=192.168.2.255 LEN=229 TOS=0x00 PREC=0x00 TTL=60 ID=966 PROTO=UDP SPT=138
> DPT=138 LEN=209
> Unable to handle kernel NULL pointer dereference at virtual address 00000000
>  printing eip:
> 00000000
> *pde = 5386a067
> Oops: 0000 [#1]
> PREEMPT
> Modules linked in: esp6 ah6 ipcomp esp4 ah4 xfrm_user arc4 af_packet lp autofs4
> tun ipx p8022 psnap llc p8023 bridge iptable_mangle ipt_TCPMSS xt_state
> ipt_REJECT ipt_LOG ipt_multiport iptable_filter ipt_MASQUERADE ipt_REDIRECT
> xt_tcpudp iptable_nat ip_tables ip6table_raw ip6table_mangle ip6t_hl xt_limit
> ip6t_multiport ip6t_LOG ip6table_filter ip6_tables x_tables ipv6 deflate
> zlib_deflate zlib_inflate sha1 crypto_null af_key binfmt_misc nfsd exportfs
> eeprom i2c_viapro ppdev ip_nat_ftp ip_nat ip_conntrack_ftp ip_conntrack
> nfnetlink ide_floppy ide_disk ide_cd snd_seq_dummy snd_seq_oss snd_seq_midi
> snd_seq_midi_event snd_seq snd_via82xx snd_ens1371 snd_pcm_oss snd_mixer_oss
> gameport snd_via82xx_modem snd_ac97_codec snd_ac97_bus snd_mpu401_uart snd_pcm
> snd_rawmidi snd_seq_device snd_timer snd via82cxxx generic psmouse
> snd_page_alloc ide_core serio_raw soundcore dl2k 8139too uhci_hcd via686a hwmon
> i2c_isa usbcore parport_pc parport unix
> CPU:    0
> EIP:    0060:[<00000000>]    Not tainted VLI
> EFLAGS: 00213246   (2.6.16.5-d6vaa-1CPU #4)
> EIP is at run_init_process+0x3feffde0/0x29
> eax: f6bff340   ebx: f6bff340   ecx: 00000003   edx: 00000003
> esi: 00000000   edi: f748e000   ebp: 00000003   esp: f748ff70
> ds: 007b   es: 007b   ss: 0068
> Process Xorg (pid: 6506, threadinfo=f748e000 task=f7a02030)
> Stack: <0>f88161f5 f5c65bc0 00000022 086c2690 f748e000 c0266151 00000000 0000000c
>        c0266b67 00000022 00000002 00000022 00000002 00000000 00000000 00000000
>        00000022 0000000d c0102a2d 0000000d bfd5c0e0 08700a38 00000022 086c2690
> Call Trace:
>  [<f88161f5>] unix_shutdown+0x54/0x125 [unix]
>  [<c0266151>] sys_shutdown+0x24/0x35
>  [<c0266b67>] sys_socketcall+0x128/0x181
>  [<c0102a2d>] syscall_call+0x7/0xb
> Code:  Bad EIP value.
>  <6>agpgart: Found an AGP 2.0 compliant device at 0000:00:00.0.
> agpgart: Putting AGP V2 device at 0000:00:00.0 into 1x mode
> agpgart: Putting AGP V2 device at 0000:01:00.0 into 1x mode
> 
> Finally I was able to reboot the system via ssh. ps -e |grep xdm was telling me,
> that no xdm was running, but xdm was showing on my frozen screen. top showed
> that the crshed machine was not under load. => no livelock
> 
> Steps to reproduce: unknown, because my machine crashes randomly
> 

The CPU has started execution at address 0x00000000.  I'd assume that
sk->sk_state_change is zero in unix_shutdown().

Could you add this patch?  If my theory is correct, it will prevent the
crashes and will give us the same info.


diff -puN net/unix/af_unix.c~a net/unix/af_unix.c
--- 25/net/unix/af_unix.c~a	Wed Apr 19 13:45:05 2006
+++ 25-akpm/net/unix/af_unix.c	Wed Apr 19 13:48:13 2006
@@ -1780,6 +1780,19 @@ out:
 	return copied ? : err;
 }
 
+static void do_sk_state_change(struct sock *sk)
+{
+	void (*sk_state_change)(struct sock *sk);
+
+	sk_state_change = sk->sk_state_change;
+	if (!sk_state_change) {
+		printk(KERN_ERR "%s: sk_state_change=NULL\n", __FUNCTION__);
+		dump_stack();
+	} else {
+		sk_state_change(sk);
+	}
+}
+
 static int unix_shutdown(struct socket *sock, int mode)
 {
 	struct sock *sk = sock->sk;
@@ -1794,7 +1807,7 @@ static int unix_shutdown(struct socket *
 		if (other)
 			sock_hold(other);
 		unix_state_wunlock(sk);
-		sk->sk_state_change(sk);
+		do_sk_state_change(sk);
 
 		if (other &&
 			(sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET)) {
@@ -1808,7 +1821,7 @@ static int unix_shutdown(struct socket *
 			unix_state_wlock(other);
 			other->sk_shutdown |= peer_mode;
 			unix_state_wunlock(other);
-			other->sk_state_change(other);
+			do_sk_state_change(other);
 			read_lock(&other->sk_callback_lock);
 			if (peer_mode == SHUTDOWN_MASK)
 				sk_wake_async(other,1,POLL_HUP);
_

