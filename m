From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2 0/3] bonding: add the debugfs interface to see RLB hash table
Date: Wed, 08 Dec 2010 12:33:02 -0800
Message-ID: <3778.1291840382@death>
References: <4CF89A00.8030902@jp.fujitsu.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:57131 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755858Ab0LHUdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 15:33:07 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oB8KFikF010154
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 15:15:57 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id AB1FA728061
	for <netdev@vger.kernel.org>; Wed,  8 Dec 2010 15:33:05 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB8KX5ew334844
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 15:33:05 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB8KX4rM012535
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 18:33:05 -0200
In-reply-to: <4CF89A00.8030902@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

>Hi Jay,
>
>Thank you for your quick review. I update my patchset according to your comment.
>But I didn't take measures against your concern about seq_file. If I come up with
>a good idea, I'll correct it.
>
>--
>This patchset provides the debugfs facility to the bonding driver and
>the interface to see RLB hashtable in it.
>
> *[PATCH 1/3] bonding: add the debugfs facility to the bonding driver
> *[PATCH 2/3] bonding: migrate some macros from bond_alb.c to bond_alb.h
> *[PATCH 3/3] bonding: add the debugfs interface to see RLB hash table

	After applying your patches to net-next-2.6, I'm seeing the
following crash when executing "rmmod bonding":

BUG: unable to handle kernel paging request at 6b6b6b9f
IP: [<c0201f11>] debugfs_remove_recursive+0x1e/0x11a
*pde = 00000000 
Oops: 0000 [#1] PREEMPT SMP 
last sysfs file: /sys/devices/virtual/net/bond0/flags
Modules linked in: bonding(-) ipv6 mperf microcode loop tg3 e1000 libphy sworks_agp agpgart edd ext3 mbcache jbd pata_serverworks mptspi mptscsih mptbase [last unloaded: speedstep_lib]

Pid: 5237, comm: rmmod Not tainted 2.6.37-rc1-cur+ #11 /eserver xSeries 335 -[8676GBX]-
EIP: 0060:[<c0201f11>] EFLAGS: 00010202 CPU: 2
EIP is at debugfs_remove_recursive+0x1e/0x11a
EAX: 6b6b6b6b EBX: f4d99480 ECX: 00000000 EDX: f3d5a5d4
ESI: f4d99950 EDI: f2d445b8 EBP: f4d03eb8 ESP: f4d03ea8
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process rmmod (pid: 5237, ti=f4d02000 task=f3d5a240 task.ti=f4d02000)
Stack:
 f4d03ec0 f4d99480 f4d99950 f4d99000 f4d03ec0 f801dc05 f4d03ef4 f8015c5b
 c0156ab6 f4d03ed8 c0134ff0 f4d9949c f4d03ee4 c037ec67 f4d99150 f4d03ef4
 f4d99000 f4d03f20 f4d99000 f4d03f08 c030eafe f4d03f20 c0ce4140 f80233a4
Call Trace:
 [<f801dc05>] ? bond_debug_unregister+0xe/0x10 [bonding]
 [<f8015c5b>] ? bond_uninit+0x324/0x36d [bonding]
 [<c0156ab6>] ? trace_hardirqs_on+0xb/0xd
 [<c0134ff0>] ? local_bh_enable_ip+0x97/0xae
 [<c037ec67>] ? _raw_spin_unlock_bh+0x2f/0x32
 [<c030eafe>] ? rollback_registered_many+0x187/0x1fb
 [<c030eb81>] ? unregister_netdevice_many+0xf/0x4d
 [<c0318890>] ? __rtnl_link_unregister+0x56/0x8a
 [<c0318f45>] ? rtnl_link_unregister+0x19/0x21
 [<f801e32d>] ? bonding_exit+0x30/0x3c [bonding]
 [<c0162ddc>] ? sys_delete_module+0x184/0x1dc
 [<c01555fe>] ? put_lock_stats+0xd/0x22
 [<c0155708>] ? lock_release_holdtime+0xf5/0xfa
 [<c01a8fa3>] ? sys_munmap+0x39/0x3f
 [<c037f098>] ? restore_all_notrace+0x0/0x18
 [<c010294c>] ? sysenter_do_call+0x12/0x32
Code: fc ff 89 d8 e8 27 77 fc ff 5b 5e 5d c3 55 89 e5 57 89 c7 56 53 83 ec 04 85 c0 0f 84 01 01 00 00 8b 40 40 85 c0 0f 84 f6 00 00 00 <83> 78 34 00 0f 84 ec 00 00 00 8b 47 34 31 d2 89 fe 05 a4 00 00 
EIP: [<c0201f11>] debugfs_remove_recursive+0x1e/0x11a SS:ESP 0068:f4d03ea8
CR2: 000000006b6b6b9f
---[ end trace e274f539dfd6ed30 ]---

	This happens regardless of activity; e.g., "insmod bonding
mode=balance-alb" followed immediately by "rmmod bonding" generates the
above.

	Any thoughts?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
