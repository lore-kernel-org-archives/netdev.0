From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Bug#577640: linux-image-2.6.33-2-amd64: Kernel warnings in netns
	thread
Date: Wed, 21 Apr 2010 17:19:05 +0200
Message-ID: <o2jb9800b71004210819t6ca61099y17be143527ccbc95@mail.gmail.com>
References: <20100413112017.8505.36380.reportbug@japot.localdomain>
	 <1271612005.3679.248.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 577640@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:48261 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543Ab0DUPTH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 11:19:07 -0400
Received: by bwz25 with SMTP id 25so8277011bwz.28
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 08:19:05 -0700 (PDT)
In-Reply-To: <1271612005.3679.248.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not starting a new thread/bug, as this is probably related...

I just discovered that in 2.6.33, if I create a veth inside a
namespace and then move one of the halves into the main namespace,
when I kill the namespace, I get one of these warnings followed by an
oops. This does not happen if the veth is created from the main ns and
then moved, nor in 2.6.32. This happens both in Qemu and on real
hardware (both amd64)

To reproduce:

$ sudo ./startns bash
# ip l a type veth
# ip l s veth0 netns 1
# exit

The full log:


[  280.655876] ------------[ cut here ]------------
[  280.655916] WARNING: at
/build/mattems-linux-2.6_2.6.33-1~experimental.4-amd64-ieqSsa/linux-2.6=
-2.6.33-1~experimental.4/debian/build/source_amd64_none/fs/sysfs/dir.c:=
487
sysfs_add_one+0xcc/0xe4()
[  280.655920] Hardware name:
[  280.655922] sysfs: cannot create duplicate filename
'/devices/virtual/net/veth0/statistics'
[  280.655924] Modules linked in: veth loop parport_pc parport snd_pcm
evdev snd_timer tpm_tis button serio_raw snd i2c_piix4 tpm soundcore
tpm_bios processor snd_page_alloc psmouse i2c_core pcspkr ext3 jbd
mbcache sg sr_mod cdrom sd_mod crc_t10dif ata_generic ata_piix libata
thermal floppy thermal_sys 8139cp 8139too mii scsi_mod [last unloaded:
scsi_wait_scan]
[  280.655954] Pid: 1276, comm: ip Not tainted 2.6.33-2-amd64 #1
[  280.655956] Call Trace:
[  280.655961]  [<ffffffff8113a399>] ? sysfs_add_one+0xcc/0xe4
[  280.655964]  [<ffffffff8113a399>] ? sysfs_add_one+0xcc/0xe4
[  280.655987]  [<ffffffff81046b81>] ? warn_slowpath_common+0x77/0xa3
[  280.655991]  [<ffffffff81046c09>] ? warn_slowpath_fmt+0x51/0x59
[  280.655994]  [<ffffffff8113a2c5>] ? sysfs_pathname+0x35/0x3d
[  280.655997]  [<ffffffff8113a2c5>] ? sysfs_pathname+0x35/0x3d
[  280.656000]  [<ffffffff8113a2c5>] ? sysfs_pathname+0x35/0x3d
[  280.656007]  [<ffffffff8113a2c5>] ? sysfs_pathname+0x35/0x3d
[  280.656031]  [<ffffffff8113a399>] ? sysfs_add_one+0xcc/0xe4
[  280.656035]  [<ffffffff8113aac5>] ? create_dir+0x4f/0x7c
[  280.656038]  [<ffffffff8113baac>] ? internal_create_group+0x51/0x15a
[  280.656062]  [<ffffffff8120f3ba>] ? device_add_groups+0x22/0x5d
[  280.656066]  [<ffffffff8120faba>] ? device_add+0x2d1/0x54a
[  280.656085]  [<ffffffff81243d22>] ? dev_change_net_namespace+0x1a1/0=
x1fc
[  280.656097]  [<ffffffff8124b625>] ? do_setlink+0x67/0x356
[  280.656101]  [<ffffffff8124c452>] ? rtnl_newlink+0x2f4/0x4f3
[  280.656104]  [<ffffffff8124c203>] ? rtnl_newlink+0xa5/0x4f3
[  280.656107]  [<ffffffff8123cdcf>] ? __skb_recv_datagram+0x11a/0x24f
[  280.656116]  [<ffffffff8123c040>] ? memcpy_toiovec+0x3d/0x6d
[  280.656124]  [<ffffffff8125d39d>] ? netlink_sendmsg+0x15f/0x252
[  280.656127]  [<ffffffff8124bf69>] ? rtnetlink_rcv_msg+0x0/0x1f5
[  280.656130]  [<ffffffff8125cf55>] ? netlink_rcv_skb+0x34/0x7c
[  280.656133]  [<ffffffff8124bf63>] ? rtnetlink_rcv+0x1f/0x25
[  280.656136]  [<ffffffff8125cd49>] ? netlink_unicast+0xe2/0x148
[  280.656139]  [<ffffffff8125d47d>] ? netlink_sendmsg+0x23f/0x252
[  280.656142]  [<ffffffff81232ea3>] ? sock_sendmsg+0x83/0x9b
[  280.656162]  [<ffffffff810b5122>] ? __alloc_pages_nodemask+0x10f/0x5=
e1
[  280.656166]  [<ffffffff8123bd03>] ? copy_from_user+0x13/0x25
[  280.656169]  [<ffffffff8123c0b9>] ? verify_iovec+0x49/0x84
[  280.656172]  [<ffffffff81233178>] ? sys_sendmsg+0x225/0x2af
[  280.656176]  [<ffffffff812343c7>] ? sys_recvmsg+0x48/0x56
[  280.656188]  [<ffffffff81008ac2>] ? system_call_fastpath+0x16/0x1b
[  280.656191] ---[ end trace f31191528d9325da ]---
[  280.658197] ------------[ cut here ]------------
[  280.658202] WARNING: at
/build/mattems-linux-2.6_2.6.33-1~experimental.4-amd64-ieqSsa/linux-2.6=
-2.6.33-1~experimental.4/debian/build/source_amd64_none/net/core/dev.c:=
5597
dev_change_net_namespace+0x1b6/0x1fc()
[  280.658205] Hardware name:
[  280.658207] Modules linked in: veth loop parport_pc parport snd_pcm
evdev snd_timer tpm_tis button serio_raw snd i2c_piix4 tpm soundcore
tpm_bios processor snd_page_alloc psmouse i2c_core pcspkr ext3 jbd
mbcache sg sr_mod cdrom sd_mod crc_t10dif ata_generic ata_piix libata
thermal floppy thermal_sys 8139cp 8139too mii scsi_mod [last unloaded:
scsi_wait_scan]
[  280.658229] Pid: 1276, comm: ip Tainted: G        W  2.6.33-2-amd64 =
#1
[  280.658231] Call Trace:
[  280.658235]  [<ffffffff81243d37>] ? dev_change_net_namespace+0x1b6/0=
x1fc
[  280.658238]  [<ffffffff81243d37>] ? dev_change_net_namespace+0x1b6/0=
x1fc
[  280.658241]  [<ffffffff81046b81>] ? warn_slowpath_common+0x77/0xa3
[  280.658245]  [<ffffffff81243d37>] ? dev_change_net_namespace+0x1b6/0=
x1fc
[  280.658248]  [<ffffffff8124b625>] ? do_setlink+0x67/0x356
[  280.658251]  [<ffffffff8124c452>] ? rtnl_newlink+0x2f4/0x4f3
[  280.658254]  [<ffffffff8124c203>] ? rtnl_newlink+0xa5/0x4f3
[  280.658257]  [<ffffffff8123cdcf>] ? __skb_recv_datagram+0x11a/0x24f
[  280.658261]  [<ffffffff8123c040>] ? memcpy_toiovec+0x3d/0x6d
[  280.658264]  [<ffffffff8125d39d>] ? netlink_sendmsg+0x15f/0x252
[  280.658267]  [<ffffffff8124bf69>] ? rtnetlink_rcv_msg+0x0/0x1f5
[  280.658270]  [<ffffffff8125cf55>] ? netlink_rcv_skb+0x34/0x7c
[  280.658273]  [<ffffffff8124bf63>] ? rtnetlink_rcv+0x1f/0x25
[  280.658275]  [<ffffffff8125cd49>] ? netlink_unicast+0xe2/0x148
[  280.658278]  [<ffffffff8125d47d>] ? netlink_sendmsg+0x23f/0x252
[  280.658281]  [<ffffffff81232ea3>] ? sock_sendmsg+0x83/0x9b
[  280.658285]  [<ffffffff810b5122>] ? __alloc_pages_nodemask+0x10f/0x5=
e1
[  280.658288]  [<ffffffff8123bd03>] ? copy_from_user+0x13/0x25
[  280.658292]  [<ffffffff8123c0b9>] ? verify_iovec+0x49/0x84
[  280.658294]  [<ffffffff81233178>] ? sys_sendmsg+0x225/0x2af
[  280.658298]  [<ffffffff812343c7>] ? sys_recvmsg+0x48/0x56
[  280.658301]  [<ffffffff81008ac2>] ? system_call_fastpath+0x16/0x1b
[  280.658304] ---[ end trace f31191528d9325db ]---
[  304.280782] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000008
[  304.282171] IP: [<ffffffff81215f17>] device_pm_remove+0x2c/0x4f
[  304.283021] PGD 0
[  304.283665] Oops: 0002 [#1] SMP
[  304.284016] last sysfs file: /sys/devices/virtual/net/lo/operstate
[  304.284016] CPU 0
[  304.284016] Pid: 9, comm: netns Tainted: G        W  2.6.33-2-amd64 =
#1 /
[  304.284016] RIP: 0010:[<ffffffff81215f17>]  [<ffffffff81215f17>]
device_pm_remove+0x2c/0x4f
[  304.284016] RSP: 0018:ffff88007fb9bd60  EFLAGS: 00010286
[  304.284016] RAX: 0000000000000000 RBX: ffff880037ccdc38 RCX: ffff880=
037ccdcd8
[  304.284016] RDX: 0000000000000000 RSI: 0000000000000006 RDI: fffffff=
f816762a0
[  304.284016] RBP: ffff880037cc9000 R08: 0000000000000000 R09: fffffff=
f812ee659
[  304.284016] R10: ffff88007fb56200 R11: 00000000000003c0 R12: 0000000=
000000000
[  304.284016] R13: ffff88007fb9be00 R14: ffff88007fb9bdc0 R15: ffff880=
07fb63800
[  304.284016] FS:  0000000000000000(0000) GS:ffff880001a00000(0000)
knlGS:0000000000000000
[  304.284016] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  304.284016] CR2: 0000000000000008 CR3: 0000000001636000 CR4: 0000000=
0000006f0
[  304.284016] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[  304.284016] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[  304.284016] Process netns (pid: 9, threadinfo ffff88007fb9a000,
task ffff88007fb63800)
[  304.284016] Stack:
[  304.284016]  ffff880037ccdc38 ffffffff8120f5fa ffff880037ccd800
ffff880037cc9000
[  304.284016] <0> ffff88007fb9bdc0 ffffffff812436aa ffff88007fb9bdc0
ffff88007fb9bdd8
[  304.284016] <0> ffff88007d1c0070 ffffffff8124371f ffff88007d1c0020
ffffffff812438a3
[  304.284016] Call Trace:
[  304.284016]  [<ffffffff8120f5fa>] ? device_del+0x33/0x1a0
[  304.284016]  [<ffffffff812436aa>] ? rollback_registered_many+0x135/0=
x19c
[  304.284016]  [<ffffffff8124371f>] ? unregister_netdevice_many+0xe/0x=
57
[  304.284016]  [<ffffffff812438a3>] ? default_device_exit_batch+0x92/0=
xa3
[  304.284016]  [<ffffffff8123e97a>] ? cleanup_net+0xfd/0x1af
[  304.284016]  [<ffffffff8105bd0d>] ? worker_thread+0x188/0x21d
[  304.284016]  [<ffffffff8123e87d>] ? cleanup_net+0x0/0x1af
[  304.284016]  [<ffffffff8105f2d2>] ? autoremove_wake_function+0x0/0x2=
e
[  304.284016]  [<ffffffff8105bb85>] ? worker_thread+0x0/0x21d
[  304.284016]  [<ffffffff8105ee99>] ? kthread+0x79/0x81
[  304.284016]  [<ffffffff810098e4>] ? kernel_thread_helper+0x4/0x10
[  304.284016]  [<ffffffff8105ee20>] ? kthread+0x0/0x81
[  304.284016]  [<ffffffff810098e0>] ? kernel_thread_helper+0x0/0x10
[  304.284016] Code: 48 89 fb 48 c7 c7 a0 62 67 81 e8 81 7b 0d 00 48
8b 93 a0 00 00 00 48 8b 83 a8 00 00 00 48 8d 8b a0 00 00 00 48 c7 c7
a0 62 67 81 <48> 89 42 08 48 89 10 48 89 8b a0 00 00 00 48 89 8b a8 00
00 00
[  304.284016] RIP  [<ffffffff81215f17>] device_pm_remove+0x2c/0x4f
[  304.284016]  RSP <ffff88007fb9bd60>
[  304.284016] CR2: 0000000000000008
[  304.330835] ---[ end trace f31191528d9325dc ]---


On Sun, Apr 18, 2010 at 19:33, Ben Hutchings <ben@decadent.org.uk> wrot=
e:
> On Tue, 2010-04-13 at 13:20 +0200, Martin Ferrari wrote:
>> Package: linux-2.6
>> Version: 2.6.33-1~experimental.4
>> Severity: normal
>> Tags: experimental
>>
>> Firstly, please note that I'm running this inside a Qemu, but I
>> imagine that it should not change things much.
>>
>> I installed 2.6.33 to try out the new improvements regarding network
>> namespaces, and while creating and killing hundreds of them, I got
>> many warnings from the kernel that might indicate a bug somewhere.
>> Please see the log already included by reportbug.
>
> I'm forwarding this to the upstream maintainers.
>
> Ben.
>
> [...]
>> [ 6696.035331] ------------[ cut here ]------------
>> [ 6696.035334] WARNING: at /build/mattems-linux-2.6_2.6.33-1~experim=
ental.4-amd64-ieqSsa/linux-2.6-2.6.33-1~experimental.4/debian/build/sou=
rce_amd64_none/kernel/sysctl.c:1894 unregister_sysctl_table+0xa6/0xd1()
>> [ 6696.035336] Hardware name:
>> [ 6696.035337] Modules linked in: veth loop parport_pc parport snd_p=
cm tpm_tis evdev snd_timer i2c_piix4 tpm tpm_bios button processor seri=
o_raw i2c_core snd soundcore snd_page_alloc pcspkr psmouse ext3 jbd mbc=
ache sg sr_mod cdrom sd_mod crc_t10dif ata_generic ata_piix libata flop=
py 8139cp thermal thermal_sys 8139too mii scsi_mod [last unloaded: veth=
]
>> [ 6696.035354] Pid: 9, comm: netns Tainted: G =A0 =A0 =A0 =A0W =A02.=
6.33-2-amd64 #1
>> [ 6696.035355] Call Trace:
>> [ 6696.035357] =A0[<ffffffff8104e303>] ? unregister_sysctl_table+0xa=
6/0xd1
>> [ 6696.035360] =A0[<ffffffff8104e303>] ? unregister_sysctl_table+0xa=
6/0xd1
>> [ 6696.035362] =A0[<ffffffff81046b81>] ? warn_slowpath_common+0x77/0=
xa3
>> [ 6696.035364] =A0[<ffffffff8104e303>] ? unregister_sysctl_table+0xa=
6/0xd1
>> [ 6696.035367] =A0[<ffffffff812b1205>] ? addrconf_ifdown+0x26f/0x2cc
>> [ 6696.035369] =A0[<ffffffff81247edc>] ? neigh_sysctl_unregister+0x1=
a/0x31
>> [ 6696.035371] =A0[<ffffffff812b1211>] ? addrconf_ifdown+0x27b/0x2cc
>> [ 6696.035374] =A0[<ffffffff812b2b0c>] ? addrconf_notify+0x714/0x7ea
>> [ 6696.035376] =A0[<ffffffff811eb2e7>] ? extract_entropy+0x6a/0x125
>> [ 6696.035379] =A0[<ffffffff81053aaf>] ? lock_timer_base+0x26/0x4b
>> [ 6696.035382] =A0[<ffffffff8123951c>] ? skb_dequeue+0x50/0x58
>> [ 6696.035384] =A0[<ffffffff812482c8>] ? pneigh_queue_purge+0x25/0x2=
f
>> [ 6696.035386] =A0[<ffffffff81249a91>] ? neigh_ifdown+0xba/0xc9
>> [ 6696.035389] =A0[<ffffffff81062f6d>] ? notifier_call_chain+0x29/0x=
4c
>> [ 6696.035392] =A0[<ffffffff81243662>] ? rollback_registered_many+0x=
ed/0x19c
>> [ 6696.035394] =A0[<ffffffff8124371f>] ? unregister_netdevice_many+0=
xe/0x57
>> [ 6696.035397] =A0[<ffffffff812438a3>] ? default_device_exit_batch+0=
x92/0xa3
>> [ 6696.035399] =A0[<ffffffff8123e97a>] ? cleanup_net+0xfd/0x1af
>> [ 6696.035402] =A0[<ffffffff8105bd0d>] ? worker_thread+0x188/0x21d
>> [ 6696.035404] =A0[<ffffffff8123e87d>] ? cleanup_net+0x0/0x1af
>> [ 6696.035406] =A0[<ffffffff8105f2d2>] ? autoremove_wake_function+0x=
0/0x2e
>> [ 6696.035409] =A0[<ffffffff8105bb85>] ? worker_thread+0x0/0x21d
>> [ 6696.035411] =A0[<ffffffff8105ee99>] ? kthread+0x79/0x81
>> [ 6696.035414] =A0[<ffffffff810098e4>] ? kernel_thread_helper+0x4/0x=
10
>> [ 6696.035416] =A0[<ffffffff8105ee20>] ? kthread+0x0/0x81
>> [ 6696.035418] =A0[<ffffffff810098e0>] ? kernel_thread_helper+0x0/0x=
10
>> [ 6696.035419] ---[ end trace ef7b93cb006e989e ]---
> [...]
>
> --
> Ben Hutchings
> Once a job is fouled up, anything done to improve it makes it worse.
>



--=20
Mart=EDn Ferrari
