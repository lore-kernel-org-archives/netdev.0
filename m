From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9375] New: divide error: 0000 [#1] with VIA
 Velocity when unplugged
Date: Tue, 13 Nov 2007 21:19:03 -0800
Message-ID: <20071113211903.518a93de.akpm@linux-foundation.org>
References: <bug-9375-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: jnelson-kernel-bugzilla@jamponi.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38660 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750798AbXKNFTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:19:08 -0500
In-Reply-To: <bug-9375-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(plesae respond via emailed reply-to-all)

On Tue, 13 Nov 2007 20:48:44 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9375
> 
>            Summary: divide error: 0000 [#1] with VIA Velocity when unplugged
>            Product: Other
>            Version: 2.5
>      KernelVersion: 2.6.22.12 (openSUSE 10.3)
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: other_other@kernel-bugs.osdl.org
>         ReportedBy: jnelson-kernel-bugzilla@jamponi.net
> 
> 
> Most recent kernel where this bug did not occur: I've never seen it before.
> Distribution: openSUSE 10.3
> Hardware Environment: AMD Athlon 2200+
> Software Environment: openSUSE 10.3
> Problem Description: I unplugged my VIA Velocity and plugged it back into a
> switch and shortly thereafter it gacked.
> 
> I ran 'ip -s -s link show dev eth1' which sigsegd (this machine has been rock
> solid for YEARS so I know it's not the hardware) and the machine locked up. The
> blinkenlights on the switch continued to blink but according to tcpdump no
> traffic was flowing from this machine. A reboot later confirmed a problem and I
> found this in the /var/log/messages file:
> 
> 
> Nov 13 22:26:54 frank kernel: divide error: 0000 [#1]
> Nov 13 22:26:54 frank kernel: SMP
> Nov 13 22:26:54 frank kernel: last sysfs file: /block/drbd0/range
> Nov 13 22:26:54 frank kernel: Modules linked in: drbd xt_tcpudp xt_pkttype
> ipt_LOG xt_limit snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device nfs lockd
> nfs_acl sunrpc af_packet ipt_REJECT xt_state iptable_mangle iptable_nat nf_nat
> iptable_filter nf_conntrack_ipv4 nf_conntrack nfnetlink ip_tables ip6_tables
> x_tables tcp_bic apparmor dm_crypt loop dm_mirror dm_log dm_mod snd_intel8x0
> snd_ac97_codec ac97_bus snd_pcm snd_timer snd i2c_sis96x soundcore parport_pc
> button sr_mod via_velocity sis_agp rtc_cmos shpchp i2c_sis630 cdrom i2c_co
> re parport agpgart snd_page_alloc rtc_core rtc_lib pci_hotplug crc_ccitt sg
> usbhid hid ff_memless ehci_hcd sd_mod ohci_hcd usbcore piix sis5513 ide_core
> edd ext3 mbcache jbd fan pata_sis libata scsi_mod thermal processor
> Nov 13 22:26:54 frank kernel: CPU:    0
> Nov 13 22:26:54 frank kernel: EIP:    0060:[<c0266de0>]    Tainted: G      N
> VLI
> Nov 13 22:26:54 frank kernel: EFLAGS: 00200287   (2.6.22.12-0.1-default #1)
> Nov 13 22:26:54 frank kernel: EIP is at sys_socketcall+0x21/0x261
> Nov 13 22:26:54 frank kernel: eax: 00000001   ebx: 0000000c   ecx: 00000001  
> edx: ffffffea
> Nov 13 22:26:54 frank kernel: esi: bfdaa27c   edi: 00000000   ebp: ef1b8000  
> esp: ef1b9f78
> Nov 13 22:26:54 frank kernel: ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss:
> 0068
> Nov 13 22:26:54 frank kernel: Process ip (pid: 4350, ti=ef1b8000 task=f3d4eab0
> task.ti=ef1b8000)
> Nov 13 22:26:54 frank kernel: Stack: 40000003 00000000 f3d4ebd8 08073160
> bfdaa140 ef1b9fb8 00000000 c0107e49
> Nov 13 22:26:54 frank kernel:        bfdaa140 08073160 bfdaa27c 00000001
> 00000001 bfdaa27c 08073184 c0104ea2
> Nov 13 22:26:54 frank kernel:        00000001 bfdaa140 08073160 bfdaa27c
> 08073184 bfdaa178 ffffffda 0000007b
> Nov 13 22:26:54 frank kernel: Call Trace:
> Nov 13 22:26:54 frank kernel:  [<c0107e49>] do_syscall_trace+0x12c/0x173
> Nov 13 22:26:54 frank kernel:  [<c0104ea2>] syscall_call+0x7/0xb
> Nov 13 22:26:54 frank kernel:  =======================
> Nov 13 22:26:54 frank kernel: Code: c4 94 00 00 00 5b 5e 5f 5d c3 57 ba ea ff
> ff ff 56 53 83 ec 30 8b 44 24 40 8d 78 ff 83 ff 10 0f 87
>  3d 02 00 00 8a 98 68 32 2e c0 <8d> 74 24 18 8b 54 24 44 89 f0 0f b6 cb e8 2a
> 9b f6 ff ba f2 ff
> Nov 13 22:26:54 frank kernel: EIP: [<c0266de0>] sys_socketcall+0x21/0x261
> SS:ESP 0068:ef1b9f78
> 
> 

hm, I see no divide instruction near the start of 2.6.22's
sys_socketcall().  I'm wondering if some patch which opensuse has added is
causing this.  If you have the source handy can you show us what it looks like?
That's net/socket.c, the 50-odd lines after

asmlinkage long sys_socketcall(int call, unsigned long __user *args)


What caused the kernel taint, btw?

Thanks.
