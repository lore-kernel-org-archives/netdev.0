From: Dave Jones <davej@redhat.com>
Subject: lockup with 2.6.31 while running sfuzz.
Date: Fri, 11 Sep 2009 16:54:49 -0400
Message-ID: <20090911205449.GA12726@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbZIKUys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 16:54:48 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n8BKspj2019436
	for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 16:54:52 -0400
Received: from gelk.kernelslacker.org (vpn-13-40.rdu.redhat.com [10.11.13.40])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n8BKsoUU030437
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 16:54:51 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n8BKsn9M012736
	for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 16:54:49 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.3/8.14.3/Submit) id n8BKsnhQ012735
	for netdev@vger.kernel.org; Fri, 11 Sep 2009 16:54:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just before locking up completely, I managed to capture this ..
Repeated it twice. Happens within a few minutes of running.

	Dave

BUG: unable to handle kernel NULL pointer dereference at 0000000000000070
IP: [<ffffffff81096d61>] __lock_acquire+0xae/0xc0e
PGD 3088f067 PUD 3146c067 PMD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/cpu3/cache/index1/shared_cpu_map
CPU 0 
Modules linked in: ip_queue sctp libcrc32c ip6_queue can_bcm sco cmtp kernelcapi bnep can_raw hidp l2cap rds rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr pppoe pppox ppp_generic slhc atm appletalk can af_key rose ax25 bluetooth rfkill ipx p8022 psnap llc p8023 decnet irda crc_ccitt gfs2 dlm configfs nfsd lockd nfs_acl auth_rpcgss sunrpc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 p4_clockmod freq_table speedstep_lib xfs exportfs vfat fat ext2 dm_multipath snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer e1000 i2c_i801 snd iTCO_wdt shpchp iTCO_vendor_support e752x_edac ppdev edac_core parport_pc soundcore snd_page_alloc dcdbas parport raid1 raid0 floppy radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: freq_table]
Pid: 1859, comm: sfuzz Not tainted 2.6.31-2.fc12.x86_64 #1 Precision WorkStation 470    
RIP: 0010:[<ffffffff81096d61>]  [<ffffffff81096d61>] __lock_acquire+0xae/0xc0e
RSP: 0018:ffff88003085fb68  EFLAGS: 00010046
RAX: 0000000000000046 RBX: ffff88003143a4a0 RCX: ffffffff81439f9c
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000068
RBP: ffff88003085fbe8 R08: 0000000000000002 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000246
R13: 0000000000000068 R14: 0000000000000002 R15: 0000000000000000
FS:  00007f3df0ecd700(0000) GS:ffff880004600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000070 CR3: 0000000030da4000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process sfuzz (pid: 1859, threadinfo ffff88003085e000, task ffff88003143a4a0)
Stack:
 ffff88003085fb78 ffffffff81019a3b ffff88003085fb88 0000000067f0b452
<0> 000000003085fbb8 0000000067f0b452 ffff880000000000 ffffffff815041ee
<0> ffffffff817e5da8 0000000067f0b452 ffff88003085fbe8 0000000000000002
Call Trace:
 [<ffffffff81019a3b>] ? native_sched_clock+0x2d/0x62
 [<ffffffff815041ee>] ? __mutex_unlock_slowpath+0x12f/0x158
 [<ffffffff810979af>] lock_acquire+0xee/0x12e
 [<ffffffff81439f9c>] ? lock_sock_nested+0x4d/0x12d
 [<ffffffff814552b5>] ? rtnl_lock+0x2a/0x40
 [<ffffffff81439f9c>] ? lock_sock_nested+0x4d/0x12d
 [<ffffffff815062a2>] _spin_lock_bh+0x4a/0x93
 [<ffffffff81439f9c>] ? lock_sock_nested+0x4d/0x12d
 [<ffffffff81439f9c>] lock_sock_nested+0x4d/0x12d
 [<ffffffffa06b20c2>] lock_sock+0x23/0x39 [can_raw]
 [<ffffffffa06b2b98>] raw_release+0x3c/0x12f [can_raw]
 [<ffffffff81436b96>] sock_release+0x32/0x98
 [<ffffffff81436c34>] sock_close+0x38/0x50
 [<ffffffff81143e21>] __fput+0x137/0x200
 [<ffffffff81143f17>] fput+0x2d/0x43
 [<ffffffff81438007>] sys_accept4+0x1f4/0x224
 [<ffffffff81141fa4>] ? fsnotify_modify+0x7b/0x9a
 [<ffffffff81011f7a>] ? sysret_check+0x2e/0x69
 [<ffffffff810c3bae>] ? audit_syscall_entry+0x12d/0x16d
 [<ffffffff81438202>] sys_accept+0x23/0x39
 [<ffffffff81011f42>] system_call_fastpath+0x16/0x1b
Code: 00 be f4 09 00 00 0f 85 0c 0b 00 00 e9 a4 0a 00 00 83 fe 07 76 11 e8 e7 aa 1e 00 48 c7 c7 3e c1 66 81 e9 c0 0a 00 00 85 f6 75 09 <49> 8b 45 08 48 85 c0 75 2b 31 d2 4c 89 ef 48 89 4d 98 4c 89 4d 
RIP  [<ffffffff81096d61>] __lock_acquire+0xae/0xc0e
 RSP <ffff88003085fb68>
CR2: 0000000000000070
---[ end trace 6d2b85c48fdea652 ]---

