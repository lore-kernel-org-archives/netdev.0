From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [2.6.28] NULL pointer dereference at get_stats()
Date: Tue, 30 Dec 2008 22:28:38 +0900
Message-ID: <2f11576a0812300528t6ed12fccg8698d33dc778b9c3@mail.gmail.com>
References: <200812302153.ECH86976.MFLOQFJHtSOOFV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:24582 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbYL3N2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 08:28:40 -0500
In-Reply-To: <200812302153.ECH86976.MFLOQFJHtSOOFV@I-love.SAKURA.ne.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

CC to netdev.

Can you reproduce this bug on native linux?
your log seems a bit strange.

it doesn't have any network card initialization log, but kernel
crashed in network driver.
in addition, loaded module list indicate your network card is pcnet32,
but pcnet32 doesn't have
get_stats() function. (instead, it has pcnet32_get_stats() )


(intentional fully quoted)
> Hello.
>
> I got this on 2.6.28 .
>
> CentOS 5.2 (gcc (GCC) 4.1.2 20071124 (Red Hat 4.1.2-42)) on VMware Workstation 6.5.1.
>
> Config is at http://I-love.SAKURA.ne.jp/tmp/config-2.6.28 .
> Full log is at http://I-love.SAKURA.ne.jp/tmp/messages6.txt .
>
> ----------------------------------------
> BIOS EBDA/lowmem at: 0009f800/0009f800
> Linux version 2.6.28 (root@tomoyo) (gcc version 4.1.2 20071124 (Red Hat 4.1.2-42)) #1 SMP Tue Dec 30 21:11:13 JST 2008
> KERNEL supported cpus:
>  Intel GenuineIntel
>  AMD AuthenticAMD
>  NSC Geode by NSC
>  Cyrix CyrixInstead
>  Centaur CentaurHauls
>  Transmeta GenuineTMx86
>  Transmeta TransmetaCPU
>  UMC UMC UMC UMC
> (... snipped ...)
> INIT: Entering runlevel: 3
>
> Entering non-interactive startup
> Applying Intel CPU microcode update: [  OK  ]
>
> Starting sysstat:  Calling the system activity data collector (sadc): BUG: unable to handle kernel NULL pointer dereference at 00000004
> IP: [<c055f2f5>] get_stats+0x1d/0x48
> Oops: 0000 [#1] SMP
> last sysfs file: /sys/class/firmware/microcode/loading
> Modules linked in: dm_mirror dm_region_hash dm_log dm_multipath dm_mod rfkill input_polldev sbs sbshc battery lp sg floppy ide_cd_mod cdrom serio_raw parport_pc parport rtc_cmos rtc_core ac button pcnet32 rtc_lib mii ata_piix i2c_piix4 libata i2c_core pcspkr mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
>
> Pid: 2459, comm: sadc Not tainted (2.6.28 #1) VMware Virtual Platform
> EIP: 0060:[<c055f2f5>] EFLAGS: 00010297 CPU: 0
> EIP is at get_stats+0x1d/0x48
> EAX: 00000000 EBX: df94c858 ECX: 00000001 EDX: 00000001
> ESI: 00000000 EDI: 00000000 EBP: 206a4abf ESP: df163f0c
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process sadc (pid: 2459, ti=df163000 task=df8c56d0 task.ti=df163000)
> Stack:
>  df94c800 dfb2ae40 df94c800 000000c8 c05bcc0f c066ee4c dfb2ae40 c04828b3
>  00000400 b7f6b000 df1dcf00 dfb2ae60 00000000 00000001 00000000 00000000
>  00000000 df8e4340 c04826ec fffffffb df1dcf00 c049f08d df163fa0 00000400
> Call Trace:
>  [<c05bcc0f>] dev_seq_show+0x1c/0x77
>  [<c04828b3>] seq_read+0x1c7/0x2a0
>  [<c04826ec>] seq_read+0x0/0x2a0
>  [<c049f08d>] proc_reg_read+0x58/0x6b
>  [<c049f035>] proc_reg_read+0x0/0x6b
>  [<c0470444>] vfs_read+0x81/0xf4
>  [<c0470720>] sys_read+0x3c/0x63
>  [<c0403841>] sysenter_do_call+0x12/0x21
> Code: ff 00 89 d8 e8 28 e6 05 00 31 c0 5b 5e c3 55 83 c9 ff 57 31 ff 56 31 f6 53 8b a8 6c 03 00 00 8d 58 58 eb 0c 89 e8 f7 d0 8b 04 88 <03> 78 04 03 30 89 c8 ba a0 9c 81 c0 e8 66 a1 f8 ff 83 f8 1f 89
> EIP: [<c055f2f5>] get_stats+0x1d/0x48 SS:ESP 0068:df163f0c
> ---[ end trace 8be667e49b995a38 ]---
> /etc/rc3.d/S03sysstat: line 34:  2459 Segmentation fault      /usr/lib/sa/sadc -F -L -
>
> [FAILED]
>
> Starting background readahead: [  OK  ]
>
> Bringing up loopback interface:  BUG: unable to handle kernel NULL pointer dereference at 00000004
> IP: [<c055f2f5>] get_stats+0x1d/0x48
> *pde = 00000000
> Oops: 0000 [#2] SMP
> last sysfs file: /sys/class/firmware/microcode/loading
> Modules linked in: dm_mirror dm_region_hash dm_log dm_multipath dm_mod rfkill input_polldev sbs sbshc battery lp sg floppy ide_cd_mod cdrom serio_raw parport_pc parport rtc_cmos rtc_core ac button pcnet32 rtc_lib mii ata_piix i2c_piix4 libata i2c_core pcspkr mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
>
> Pid: 2534, comm: ip Tainted: G      D    (2.6.28 #1) VMware Virtual Platform
> EIP: 0060:[<c055f2f5>] EFLAGS: 00010297 CPU: 0
> EIP is at get_stats+0x1d/0x48
> EAX: 00000000 EBX: df94c858 ECX: 00000001 EDX: 00000001
> ESI: 00000000 EDI: 00000000 EBP: 206a4abf ESP: df0b0c88
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process ip (pid: 2534, ti=df0b0000 task=df8c7b60 task.ti=df0b0000)
> Stack:
>  df99a08c df94c964 deda4780 df94c800 c05c571a 0000000b df99a000 dfb2a940
>  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00004034
>  df94c800 dfb2a940 00000000 deda4780 c05c5fe7 000009e6 495a15d3 00000000
> Call Trace:
>  [<c05c571a>] rtnl_fill_ifinfo+0x2c9/0x498
>  [<c05c5fe7>] rtnl_dump_ifinfo+0x40/0x69
>  [<c05d0cff>] netlink_dump+0x4a/0x163
>  [<c05d2812>] netlink_dump_start+0xf9/0x11c
>  [<c05c5fa7>] rtnl_dump_ifinfo+0x0/0x69
>  [<c05c5d59>] rtnetlink_rcv_msg+0xad/0x1ac
>  [<c05c5fa7>] rtnl_dump_ifinfo+0x0/0x69
>  [<c05c5cac>] rtnetlink_rcv_msg+0x0/0x1ac
>  [<c05d1a0c>] netlink_rcv_skb+0x2d/0x71
>  [<c05c5ca6>] rtnetlink_rcv+0x14/0x1a
>  [<c05d1836>] netlink_unicast+0x1a2/0x205
>  [<c05d1f0b>] netlink_sendmsg+0x24a/0x257
>  [<c05b44c4>] sock_sendmsg+0xc7/0xe1
>  [<c0434958>] autoremove_wake_function+0x0/0x2d
>  [<c0450d0c>] sync_page+0x0/0x36
>  [<c044f17d>] __delayacct_blkio_end+0x56/0x59
>  [<c0629b6b>] io_schedule+0x65/0x81
>  [<c0629c9d>] __wait_on_bit_lock+0x4b/0x52
>  [<c0450ba2>] find_get_page+0x1d/0x7a
>  [<c04ee9d9>] copy_from_user+0x23/0x4f
>  [<c05b4e0a>] sys_sendto+0xfc/0x127
>  [<c045c52d>] __do_fault+0x2fb/0x33d
>  [<c05b5719>] sys_socketcall+0xfc/0x1a9
>  [<c0403841>] sysenter_do_call+0x12/0x21
> Code: ff 00 89 d8 e8 28 e6 05 00 31 c0 5b 5e c3 55 83 c9 ff 57 31 ff 56 31 f6 53 8b a8 6c 03 00 00 8d 58 58 eb 0c 89 e8 f7 d0 8b 04 88 <03> 78 04 03 30 89 c8 ba a0 9c 81 c0 e8 66 a1 f8 ff 83 f8 1f 89
> EIP: [<c055f2f5>] get_stats+0x1d/0x48 SS:ESP 0068:df0b0c88
> ---[ end trace 8be667e49b995a38 ]---
> ----------------------------------------
>
> After doing "chkconfig microcode_ctl off" and reboot, I got below.
>
> ----------------------------------------
> (... snipped ...)
> INIT: Entering runlevel: 3
>
> Entering non-interactive startup
> Starting sysstat:  Calling the system activity data collector (sadc): BUG: unable to handle kernel NULL pointer dereference at 00000004
> IP: [<c055f2f5>] get_stats+0x1d/0x48
> Oops: 0000 [#1] SMP
> last sysfs file: /sys/block/hda/removable
> Modules linked in: dm_mirror dm_region_hash dm_log dm_multipath dm_mod rfkill input_polldev sbs sbshc battery lp sg floppy ide_cd_mod cdrom serio_raw parport_pc parport rtc_cmos rtc_core rtc_lib ac pcnet32 button mii ata_piix libata i2c_piix4 pcspkr i2c_core mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
>
> Pid: 2417, comm: sadc Not tainted (2.6.28 #1) VMware Virtual Platform
> EIP: 0060:[<c055f2f5>] EFLAGS: 00010297 CPU: 0
> EIP is at get_stats+0x1d/0x48
> EAX: 00000000 EBX: df94b858 ECX: 00000001 EDX: 00000001
> ESI: 00000000 EDI: 00000000 EBP: 206a5abf ESP: df396f0c
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process sadc (pid: 2417, ti=df396000 task=df87edb0 task.ti=df396000)
> Stack:
>  df94b800 df970f00 df94b800 000000c8 c05bcc0f c066ee4c df970f00 c04828b3
>  00000400 b7f93000 dfb89380 df970f20 00000000 00000001 00000000 00000000
>  00000000 df8e1340 c04826ec fffffffb dfb89380 c049f08d df396fa0 00000400
> Call Trace:
>  [<c05bcc0f>] dev_seq_show+0x1c/0x77
>  [<c04828b3>] seq_read+0x1c7/0x2a0
>  [<c04826ec>] seq_read+0x0/0x2a0
>  [<c049f08d>] proc_reg_read+0x58/0x6b
>  [<c049f035>] proc_reg_read+0x0/0x6b
>  [<c0470444>] vfs_read+0x81/0xf4
>  [<c0470720>] sys_read+0x3c/0x63
>  [<c0403841>] sysenter_do_call+0x12/0x21
> Code: ff 00 89 d8 e8 28 e6 05 00 31 c0 5b 5e c3 55 83 c9 ff 57 31 ff 56 31 f6 53 8b a8 6c 03 00 00 8d 58 58 eb 0c 89 e8 f7 d0 8b 04 88 <03> 78 04 03 30 89 c8 ba a0 9c 81 c0 e8 66 a1 f8 ff 83 f8 1f 89
> EIP: [<c055f2f5>] get_stats+0x1d/0x48 SS:ESP 0068:df396f0c
> ---[ end trace 51b8087926b0fb03 ]---
> /etc/rc3.d/S03sysstat: line 34:  2417 Segmentation fault      /usr/lib/sa/sadc -F -L -
>
> [FAILED]
>
> Starting background readahead: [  OK  ]
>
> Bringing up loopback interface:  BUG: unable to handle kernel NULL pointer dereference at 00000004
> IP: [<c055f2f5>] get_stats+0x1d/0x48
> *pde = 00000000
> Oops: 0000 [#2] SMP
> last sysfs file: /sys/block/hda/removable
> Modules linked in: dm_mirror dm_region_hash dm_log dm_multipath dm_mod rfkill input_polldev sbs sbshc battery lp sg floppy ide_cd_mod cdrom serio_raw parport_pc parport rtc_cmos rtc_core rtc_lib ac pcnet32 button mii ata_piix libata i2c_piix4 pcspkr i2c_core mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
>
> Pid: 2492, comm: ip Tainted: G      D    (2.6.28 #1) VMware Virtual Platform
> EIP: 0060:[<c055f2f5>] EFLAGS: 00010297 CPU: 0
> EIP is at get_stats+0x1d/0x48
> EAX: 00000000 EBX: df94b858 ECX: 00000001 EDX: 00000001
> ESI: 00000000 EDI: 00000000 EBP: 206a5abf ESP: deea4c88
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process ip (pid: 2492, ti=deea4000 task=df87edb0 task.ti=deea4000)
> Stack:
>  dee5908c df94b964 df1c36c0 df94b800 c05c571a dedc3040 dee59000 df93e916
>  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00004034
>  df94b800 df16b9c0 00000000 df1c36c0 c05c5fe7 000009bc 495a1819 00000000
> Call Trace:
>  [<c05c571a>] rtnl_fill_ifinfo+0x2c9/0x498
>  [<c05c5fe7>] rtnl_dump_ifinfo+0x40/0x69
>  [<c05d0cff>] netlink_dump+0x4a/0x163
>  [<c05d2812>] netlink_dump_start+0xf9/0x11c
>  [<c05c5fa7>] rtnl_dump_ifinfo+0x0/0x69
>  [<c05c5d59>] rtnetlink_rcv_msg+0xad/0x1ac
>  [<c05c5fa7>] rtnl_dump_ifinfo+0x0/0x69
>  [<c04dfad4>] __generic_unplug_device+0x1a/0x1c
>  [<c05c5cac>] rtnetlink_rcv_msg+0x0/0x1ac
>  [<c05d1a0c>] netlink_rcv_skb+0x2d/0x71
>  [<c05c5ca6>] rtnetlink_rcv+0x14/0x1a
>  [<c05d1836>] netlink_unicast+0x1a2/0x205
>  [<c05d1f0b>] netlink_sendmsg+0x24a/0x257
>  [<c05b44c4>] sock_sendmsg+0xc7/0xe1
>  [<c0434958>] autoremove_wake_function+0x0/0x2d
>  [<c0450d0c>] sync_page+0x0/0x36
>  [<c044f17d>] __delayacct_blkio_end+0x56/0x59
>  [<c0629b6b>] io_schedule+0x65/0x81
>  [<c0629c9d>] __wait_on_bit_lock+0x4b/0x52
>  [<c0450ba2>] find_get_page+0x1d/0x7a
>  [<c04ee9d9>] copy_from_user+0x23/0x4f
>  [<c05b4e0a>] sys_sendto+0xfc/0x127
>  [<c045c52d>] __do_fault+0x2fb/0x33d
>  [<c05b5719>] sys_socketcall+0xfc/0x1a9
>  [<c0403841>] sysenter_do_call+0x12/0x21
> Code: ff 00 89 d8 e8 28 e6 05 00 31 c0 5b 5e c3 55 83 c9 ff 57 31 ff 56 31 f6 53 8b a8 6c 03 00 00 8d 58 58 eb 0c 89 e8 f7 d0 8b 04 88 <03> 78 04 03 30 89 c8 ba a0 9c 81 c0 e8 66 a1 f8 ff 83 f8 1f 89
> EIP: [<c055f2f5>] get_stats+0x1d/0x48 SS:ESP 0068:deea4c88
> ---[ end trace 51b8087926b0fb03 ]---
> ----------------------------------------
>
> This bug resembles the one I reported at http://lkml.org/lkml/2008/11/28/99 .
>
> Regards.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
