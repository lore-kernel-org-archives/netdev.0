From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: 3.7.10 and  net_namespace_list oops - a known issue?
Date: Tue, 19 Mar 2013 09:29:58 +0100
Message-ID: <201303190929.58593.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:64812 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048Ab3CSIaC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 04:30:02 -0400
Received: by mail-ea0-f179.google.com with SMTP id f15so85883eak.38
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 01:30:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello.

I have one machine with 3.7.10 kernel and vserver patch
(http://vserver.13thfloor.at/Experimental/patch-3.7.10-vs2.3.5.6.diff).

It oopses at net_namespace_list.

Is such thing a known issue in vanilla kernel? Googling shows no simila=
r reports unfortunately.
vserver people think it's vserver unrelated (but who knows).

containers are not used here, network namespace is also not used.

Sometimes it oopses early, sometimes few days after, exim was always in=
volved in several
such oopses I saw.

 [   90.663896] BUG: unable to handle kernel paging request at 00000000=
f2fa46bb
[   90.668765] IP: [<ffffffff818661c2>] net_namespace_list+0x2/0x20
[   90.668765] PGD 1c0e13067 PUD 1c0f24067 PMD 0=20
[   90.703789] Oops: 0002 [#1] SMP=20
[   90.703789] Modules linked in: ipmi_watchdog sch_sfq dm_mod ipmi_dev=
intf ipmi_si ipmi_msghandler ide_cd_mod cdrom ata_generic pata_acpi ses=
 enclosure pata_amd evdev=20
sata_nv libata pcspkr serio_raw k8temp hwmon amd64_edac_mod edac_core e=
dac_mce_amd floppy i2c_nforce2 hid_generic forcedeth processor shpchp p=
ci_hotplug kvm_amd kvm=20
ide_pci_generic amd74xx ide_core i2c_core button xfs sd_mod crc_t10dif =
aacraid scsi_mod usbhid hid ohci_hcd ehci_hcd usbcore usb_common
[   90.703789] CPU 1=20
[   90.703789] Pid: 3847, xid: #1600, comm: exim Not tainted 3.7.10-1 #=
1 Supermicro H8SMU/H8SMU
[   90.703789] RIP: 0010:[<ffffffff818661c2>]  [<ffffffff818661c2>] net=
_namespace_list+0x2/0x20
[   90.703789] RSP: 0018:ffff8801c0c65b68  EFLAGS: 00210246
[   90.703789] RAX: ffffffff81865480 RBX: ffff8801f4d99700 RCX: 0000000=
0f2fa46bc
[   90.703789] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff880=
1d467b840
[   90.703789] RBP: ffff8801c0c65be8 R08: ffff8801c0c65fd8 R09: 0000000=
000000000
[   90.703789] R10: ffff88020d37ab80 R11: 0000000000000003 R12: ffff880=
20d37ab80
[   90.703789] R13: ffff8801d467b840 R14: ffff8801be8e484e R15: ffff880=
1be8e485a
[   90.703789] FS:  00007f0b663a6700(0000) GS:ffff88021fd00000(0063) kn=
lGS:00000000f6717700
[   90.703789] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[   90.703789] CR2: 00000000f2fa46bb CR3: 00000001c0e14000 CR4: 0000000=
0000007e0
[   90.703789] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[   90.703789] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[   90.703789] Process exim (pid: 3847, threadinfo ffff8801c0c64000, ta=
sk ffff88021247da30)
[   90.703789] Stack:
[   90.703789]  ffff8801c0c65b70 ffffffff8142be7c 0000000000000000 0000=
000000200246
[   90.703789]  ffff8801c0c65ba8 ffff8801be8e4862 0000000000000000 ffff=
8801c0c65c80
[   90.703789]  ffff8801c0c65c08 00000000287eac5f ffff8801c0c65bc8 ffff=
88020d37ab80
[   90.703789] Call Trace:
[   90.703789]  [<ffffffff8142be7c>] ? tcp_v4_do_rcv+0x2cc/0x4c0
[   90.703789]  [<ffffffff81416d07>] tcp_prequeue_process+0x67/0xb0
[   90.703789]  [<ffffffff8141a8ff>] tcp_recvmsg+0xa8f/0xd70
[   90.703789]  [<ffffffff8143fcda>] inet_recvmsg+0x4a/0x80
[   90.703789]  [<ffffffff814407c5>] ? inet_sendmsg+0x45/0xb0
[   90.703789]  [<ffffffff813bffa2>] sock_aio_read.part.9+0x142/0x1c0
[   90.703789]  [<ffffffff813c0041>] sock_aio_read+0x21/0x30
[   90.703789]  [<ffffffff8117a7f7>] do_sync_read+0xa7/0xe0
[   90.703789]  [<ffffffff8117afed>] vfs_read+0x15d/0x180
[   90.703789]  [<ffffffff8117b05d>] sys_read+0x4d/0xa0
[   90.703789]  [<ffffffff8118ed26>] ? sys_poll+0x66/0x100
[   90.703789]  [<ffffffff814ea6ec>] cstar_dispatch+0x7/0x21
[   90.703789] Code: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0=
0 90 54 <86> 81 ff ff ff ff 90 54 86 81 ff=20
ff ff ff 00 00 00 00 00 00 00=20
[   90.703789] RIP  [<ffffffff818661c2>] net_namespace_list+0x2/0x20
[   90.703789]  RSP <ffff8801c0c65b68>
[   90.703789] CR2: 00000000f2fa46bb
[   91.531561] ---[ end trace f29e53e8c0132ced ]---
[   91.545398] Kernel panic - not syncing: Fatal exception in interrupt
[   91.548728] Rebooting in 60 seconds..

http://pastebin.com/cSCfFgcy
http://pastebin.com/3XtkMbR5

--=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / maven.pl
