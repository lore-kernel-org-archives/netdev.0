From: Charles-Edouard Ruault <ce@ruault.com>
Subject: Re: [BUG] 2.6.20 Oopses in xfrm_audit_log
Date: Mon, 12 Feb 2007 22:14:09 +0100
Message-ID: <45D0D8A1.5010401@ruault.com>
References: <45D076A4.50009@ruault.com> <20070212182049.GA5677@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090901000706030803020603"
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix2-g20.free.fr ([212.27.60.43]:48416 "EHLO
	postfix2-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965418AbXBLVPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 16:15:16 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix2-g20.free.fr (Postfix) with ESMTP id 42F10A63DB6
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 21:15:23 +0100 (CET)
In-Reply-To: <20070212182049.GA5677@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090901000706030803020603
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Alexey Dobriyan wrote:
> [removing l-k from CC, and switching to netdev]
>
> Please, send your .config.
> Is it reproducible?
>
> On Mon, Feb 12, 2007 at 03:16:04PM +0100, Charles-Edouard Ruault wrote:
>   
>> i upgraded to vanilla kernel 2.6.20 and while i was using strongswan 
>> 2.8.2 to setup an IPSEC VPN i got the following kernel Ooops.
>> I had successfully established the same tunnel a few times, but key 
>> renegotiation caused a problem ( both ends did not renegotiate at the 
>> same time so the tunnel was frozen ), i decided to kill the tunnel and 
>> start a new one ( using ipsec auto --down tunnel & ipsec auto --up 
>> tunnel ), while i was doing so, i got the oops.
>>
>> BUG: unable to handle kernel NULL pointer dereference at virtual address 
>> 00000188
>> printing eip:
>> c02fb85c
>> *pde = 00000000
>> Oops: 0000 [#1]
>> PREEMPT
>> Modules linked in: xfrm4_mode_tunnel usblp deflate zlib_deflate twofish 
>> twofish_common serpent blowfish des cbc ecb blkcipher xcbc sha256 sha1 
>> crypto_null xfrm4_tunnel tunnel4 ipcomp esp4 ah4 af_key autofs4 asb100 
>> hwmon_vid hidp rfcomm l2cap bluetooth sunrpc nf_conntrack_netbios_ns 
>> ipt_LOG xt_limit xt_mark xt_state xt_tcpudp iptable_filter 
>> ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 xt_MARK 
>> iptable_mangle ip_tables x_tables binfmt_misc sd_mod ipv6 sg hfsplus 
>> video button ac lp parport_pc parport floppy nvram usb_storage scsi_mod 
>> libusual usbhid hid ehci_hcd snd_via82xx snd_ac97_codec ac97_bus 
>> ohci1394 snd_seq_dummy uhci_hcd ieee1394 snd_seq_oss snd_seq_midi_event 
>> snd_seq snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc 
>> snd_mpu401_uart snd_rawmidi snd_seq_device snd via_agp agpgart 
>> i2c_viapro soundcore eepro100 i2c_core b44 pcspkr mii shpchp usbcore dm_mod
>> CPU:    0
>> EIP:    0060:[<c02fb85c>]    Not tainted VLI
>> EFLAGS: 00010246   (2.6.20 #1)
>> EIP is at xfrm_audit_log+0x4cc/0x580
>> eax: ecb71061   ebx: c039d160   ecx: 00000000   edx: 00000021
>> esi: 000001f4   edi: 00000255   ebp: 00000000   esp: e8cd5a18
>> ds: 007b   es: 007b   ss: 0068
>> Process pluto (pid: 27486, ti=e8cd4000 task=d3557070 task.ti=e8cd4000)
>> Stack: c17d2ea0 c0354bf1 e183f9c0 00000003 c03ac59c e1399800 00000001 
>> 00000003
>>       f8d0a450 00000000 00000001 00000286 e8cd5a6c c011506b 00000000 
>> 00000286
>>       f73cb8c0 00000246 c17d2ea0 00000000 00000000 f73cb8c0 f8d03c67 
>> 00000000
>> Call Trace:
>> [<c011506b>] __wake_up+0x4b/0x80
>> [<f8d03c67>] pfkey_broadcast+0x137/0x1b0 [af_key]
>> [<f8d03e5f>] pfkey_send_policy_notify+0xef/0x1a0 [af_key]
>> [<c011d90e>] local_bh_enable+0x2e/0xa0
>> [<c0306107>] xfrm_get_policy+0x2b7/0x2f0
>> [<c0305e50>] xfrm_get_policy+0x0/0x2f0
>> [<c0304702>] xfrm_user_rcv_msg+0x102/0x1b0
>> [<c0304600>] xfrm_user_rcv_msg+0x0/0x1b0
>> [<c02b3782>] netlink_run_queue+0x82/0x120
>> [<c03045e8>] xfrm_netlink_rcv+0x28/0x40
>> [<c02b3d42>] netlink_data_ready+0x12/0x50
>> [<c02b2931>] netlink_sendskb+0x21/0x40
>> [<c02b3c50>] netlink_sendmsg+0x230/0x310
>> [<c02993cd>] sock_aio_write+0x11d/0x130
>> [<c01d538a>] avc_has_perm+0x5a/0x70
>> [<c0163ed5>] do_sync_write+0xd5/0x120
>> [<c012c960>] autoremove_wake_function+0x0/0x50
>> [<c01648c7>] vfs_write+0x177/0x180
>> [<c0164ea1>] sys_write+0x41/0x70
>> [<c0102f14>] syscall_call+0x7/0xb
>> =======================
>> Code: 8b 44 24 70 c1 e2 08 c1 e8 08 09 c2 0f b7 c2 89 44 24 08 8b 44 24 
>> 48 89 04 24 e8 10 eb e3 ff e9 bc fc ff ff 8b 8c 24 c0 00 00 00 <8b> 91 
>> 88 01 00 00 0f b7 99 82 00 00 00 85 d2 0f 85 64 fc ff ff
>> EIP: [<c02fb85c>] xfrm_audit_log+0x4cc/0x580 SS:ESP 0068:e8cd5a18
>>
>> I'm running a vanilla 2.6.20 kernel on a Fedora Core 5 box on an athlon 
>> processor:
>> cat /proc/cpuinfo
>> processor       : 0
>> vendor_id       : AuthenticAMD
>> cpu family      : 6
>> model           : 8
>> model name      : AMD Athlon(TM) XP 2400+
>> stepping        : 1
>> cpu MHz         : 2000.256
>> cache size      : 256 KB
>> fdiv_bug        : no
>> hlt_bug         : no
>> f00f_bug        : no
>> coma_bug        : no
>> fpu             : yes
>> fpu_exception   : yes
>> cpuid level     : 1
>> wp              : yes
>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
>> mca cmov pat pse36 mmx fxsr sse syscall mmxext 3dnowext 3dnow ts
>> bogomips        : 4003.78
>> clflush size    : 32
>>
>> uname -a
>> Linux machine 2.6.20 #1 PREEMPT Sat Feb 10 13:48:56 CET 2007 i686 athlon 
>> i386 GNU/Linux
>>
>> Please CC me in follow ups since i do not subscribe to the list.
>>     
>
>   
here's my config.gz attached.
I don't know if it's reproducible, i have not had the time to reboot &
try again yet ....
I just applied the patch that Joy sent. I'm trying with the patched
kernel and let the list know if it happens again.


-- 
Charles-Edouard Ruault
PGP Key ID E4D2B80C


--------------090901000706030803020603
Content-Type: application/x-gzip;
 name="config.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="config.gz"

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
JPwPm5qQmUvOAAA=
--------------090901000706030803020603--
