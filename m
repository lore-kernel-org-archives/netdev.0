From: Dieter Ries <clip2@gmx.de>
Subject: Current Git: BUG: unable to handle kernel paging request at 0000000001a40ca0
Date: Wed, 23 Jul 2008 17:39:22 +0200
Message-ID: <488750AA.20707@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp0.ethz.ch ([82.130.70.14]:42091 "EHLO XSMTP0.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872AbYGWPyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 11:54:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just encountered a Bug in latest git:

As this is my first bugreport, I am not sure who to cc and which 
information to provide, so please advise me. Some information is below.



ifconfig triggered:

BUG: unable to handle kernel paging request at 0000000001a40ca0
IP: [<ffffffff80290632>] kmem_cache_alloc+0x50/0x81
PGD 79d33067 PUD 79cf7067 PMD 0
Oops: 0000 [1] SMP
CPU 0
Modules linked in: radeon drm uinput snd_hda_intel iwl3945 snd_pcm 
snd_timer rfkill snd led_class snd_page_alloc
Pid: 3516, comm: ifconfig Not tainted 2.6.26-06077-gc010b2f #23
RIP: 0010:[<ffffffff80290632>]  [<ffffffff80290632>] 
kmem_cache_alloc+0x50/0x81
RSP: 0000:ffff880079d079e8  EFLAGS: 00010006
RAX: 0000000000000000 RBX: 0000000000000296 RCX: ffffffff802704ae
RDX: ffff880001016700 RSI: 0000000001a40ca0 RDI: ffffffff808b5fa0
RBP: ffff880079d07a08 R08: 000000000000000c R09: 0000000000000001
R10: ffff880079d07a18 R11: ffff880079cce260 R12: 0000000000011280
R13: 0000000000000080 R14: 00000000000112d0 R15: 0000000001670328
FS:  00007fb32edc26f0(0000) GS:ffffffff808b6e80(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000001a40ca0 CR3: 0000000079d43000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ifconfig (pid: 3516, threadinfo ffff880079d06000, task 
ffff88007f8ed6c0)
Stack:  ffff880079d07a18 00000000000000d0 ffff88007f99e480 0000000000000001
  ffff880079d07a18 ffffffff802704ae ffff880079d07a78 ffffffff802705c2
  ffff88007d01e400 ffffffff80865dc0 ffff880079cced10 0000000000000008
Call Trace:
  [<ffffffff802704ae>] mempool_alloc_slab+0x16/0x18
  [<ffffffff802705c2>] mempool_alloc+0x3e/0xfa
  [<ffffffff802b8db7>] bio_alloc_bioset+0x27/0x94
  [<ffffffff802b8e7e>] bio_alloc+0x15/0x24
  [<ffffffff802bc0ef>] mpage_alloc+0x2b/0x84
  [<ffffffff802bcbb5>] do_mpage_readpage+0x406/0x508
  [<ffffffff80279916>] ? __inc_zone_page_state+0x23/0x25
  [<ffffffff8026e3a8>] ? add_to_page_cache+0x81/0x98
  [<ffffffff80302fd0>] ? ext3_get_block+0x0/0xee
  [<ffffffff802bce2d>] mpage_readpages+0xab/0xeb
  [<ffffffff80302fd0>] ? ext3_get_block+0x0/0xee
  [<ffffffff802731e8>] ? __alloc_pages_internal+0xdb/0x3a1
  [<ffffffff803024a7>] ext3_readpages+0x1f/0x21
  [<ffffffff8027533b>] __do_page_cache_readahead+0x100/0x18f
  [<ffffffff802757a4>] do_page_cache_readahead+0x57/0x67
  [<ffffffff802701d3>] filemap_fault+0x165/0x342
  [<ffffffff8027adb7>] __do_fault+0x55/0x373
  [<ffffffff8027d816>] handle_mm_fault+0x1ec/0x673
  [<ffffffff80678902>] do_page_fault+0x43c/0x7e2
  [<ffffffff80676869>] error_exit+0x0/0x51


Code: 98 48 8b 94 c7 e0 00 00 00 48 8b 32 44 8b 6a 18 48 85 f6 75 13 49 
89 d0 44 89 e6 83 ca ff e8 b3 f8 ff ff 48 89 c6 eb 0a 8b 42 14 <48> 8b 
04 c6 48 89 02 53 9d 31 c0 41 c1 ec 0f 48 85 f6 0f 95 c0
RIP  [<ffffffff80290632>] kmem_cache_alloc+0x50/0x81
  RSP <ffff880079d079e8>
CR2: 0000000001a40ca0
---[ end trace a3dee77ef1628c0f ]---
BUG: unable to handle kernel paging request at 0000000001a40ca0
IP: [<ffffffff80290632>] kmem_cache_alloc+0x50/0x81
PGD 79d33067 PUD 79cf7067 PMD 0
Oops: 0000 [2] SMP
CPU 0
Modules linked in: radeon drm uinput snd_hda_intel iwl3945 snd_pcm 
snd_timer rfkill snd led_class snd_page_alloc
Pid: 1268, comm: kjournald Tainted: G      D   2.6.26-06077-gc010b2f #23
RIP: 0010:[<ffffffff80290632>]  [<ffffffff80290632>] 
kmem_cache_alloc+0x50/0x81
RSP: 0000:ffff88007d02dcd0  EFLAGS: 00010006
RAX: 0000000000000000 RBX: 0000000000000282 RCX: ffffffff802704ae
RDX: ffff880001016700 RSI: 0000000001a40ca0 RDI: ffffffff808b5fa0
RBP: ffff88007d02dcf0 R08: 0000000000000000 R09: ffff88007b04e840
R10: ffff88007c9b74d0 R11: ffff88007d02dd60 R12: 0000000000011200
R13: 0000000000000080 R14: 0000000000011210 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffffffff808b6e80(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000001a40ca0 CR3: 0000000079d43000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kjournald (pid: 1268, threadinfo ffff88007d02c000, task 
ffff88007d6b2b60)
Stack:  ffff88007f424900 0000000000000010 ffff88007f99e480 0000000000000001
  ffff88007d02dd00 ffffffff802704ae ffff88007d02dd60 ffffffff802705c2
  ffff88007b0b3000 ffff880079c5ce40 ffff88007b04e840 0000000000000004
Call Trace:
  [<ffffffff802704ae>] mempool_alloc_slab+0x16/0x18
  [<ffffffff802705c2>] mempool_alloc+0x3e/0xfa
  [<ffffffff802b8db7>] bio_alloc_bioset+0x27/0x94
  [<ffffffff80316277>] ? journal_write_metadata_buffer+0x30e/0x328
  [<ffffffff802b8e7e>] bio_alloc+0x15/0x24
  [<ffffffff802b4ebb>] submit_bh+0x78/0x119
  [<ffffffff803129dc>] journal_commit_transaction+0x76d/0xccd
  [<ffffffff8023e0df>] ? try_to_del_timer_sync+0x5b/0x67
  [<ffffffff8031596b>] kjournald+0xc8/0x200
  [<ffffffff80247f9d>] ? autoremove_wake_function+0x0/0x3d
  [<ffffffff803158a3>] ? kjournald+0x0/0x200
  [<ffffffff80247e6a>] kthread+0x4e/0x7c
  [<ffffffff8020c289>] child_rip+0xa/0x11
  [<ffffffff80247e1c>] ? kthread+0x0/0x7c
  [<ffffffff8020c27f>] ? child_rip+0x0/0x11


Code: 98 48 8b 94 c7 e0 00 00 00 48 8b 32 44 8b 6a 18 48 85 f6 75 13 49 
89 d0 44 89 e6 83 ca ff e8 b3 f8 ff ff 48 89 c6 eb 0a 8b 42 14 <48> 8b 
04 c6 48 89 02 53 9d 31 c0 41 c1 ec 0f 48 85 f6 0f 95 c0
RIP  [<ffffffff80290632>] kmem_cache_alloc+0x50/0x81
  RSP <ffff88007d02dcd0>
CR2: 0000000001a40ca0
---[ end trace a3dee77ef1628c0f ]---
BUG: unable to handle kernel paging request at 0000000001a40ca0
IP: [<ffffffff80290632>] kmem_cache_alloc+0x50/0x81
PGD 7d1ac067 PUD 7bcb9067 PMD 0
Oops: 0000 [3] SMP
CPU 0
Modules linked in: radeon drm uinput snd_hda_intel iwl3945 snd_pcm 
snd_timer rfkill snd led_class snd_page_alloc
Pid: 119, comm: kblockd/0 Tainted: G      D   2.6.26-06077-gc010b2f #23
RIP: 0010:[<ffffffff80290632>]  [<ffffffff80290632>] 
kmem_cache_alloc+0x50/0x81
RSP: 0018:ffff88007fadfcb0  EFLAGS: 00010006
RAX: 0000000000000000 RBX: 0000000000000082 RCX: ffffffff804c6b64
RDX: ffff880001016700 RSI: 0000000001a40ca0 RDI: ffffffff808b5fa0
RBP: ffff88007fadfcd0 R08: 0000000000000000 R09: ffff88007c1ef3c0
R10: ffff88007d44e890 R11: 0000000000000001 R12: 0000000000000020
R13: 0000000000000080 R14: ffff88007d5aa800 R15: 0000000000000008
FS:  0000000000000000(0000) GS:ffffffff808b6e80(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000001a40ca0 CR3: 000000007d1ad000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kblockd/0 (pid: 119, threadinfo ffff88007fade000, task 
ffff88007f8dd6c0)
Stack:  0000000000000001 0000000000000020 ffffffff808894c0 ffff88007c1ef3c0
  ffff88007fadfd00 ffffffff804c6b64 ffff88007fadfd40 ffff88007d60e800
  ffff88007d5aa920 0000000000000000 ffff88007fadfd30 ffffffff804c6c72
Call Trace:
  [<ffffffff804c6b64>] scsi_pool_alloc_command+0x4d/0x73
  [<ffffffff804c6c72>] __scsi_get_command+0x1e/0x9c
  [<ffffffff804c6d26>] scsi_get_command+0x36/0xa5
  [<ffffffff804cb1e8>] scsi_get_cmd_from_req+0x2a/0x5e
  [<ffffffff804cb5ec>] scsi_setup_fs_cmnd+0x5d/0x87
  [<ffffffff804ebc53>] sd_prep_fn+0x66/0x449
  [<ffffffff803ebed1>] elv_next_request+0xe3/0x1a4
  [<ffffffff804cc490>] scsi_request_fn+0x80/0x334
  [<ffffffff803ec5cf>] ? blk_unplug_work+0x0/0x1b
  [<ffffffff803edaee>] __generic_unplug_device+0x29/0x2e
  [<ffffffff803ee5de>] generic_unplug_device+0x2e/0x3c
  [<ffffffff803ec5e8>] blk_unplug_work+0x19/0x1b
  [<ffffffff80244890>] run_workqueue+0x81/0x10a
  [<ffffffff8024529d>] worker_thread+0xdd/0xea
  [<ffffffff80247f9d>] ? autoremove_wake_function+0x0/0x3d
  [<ffffffff802451c0>] ? worker_thread+0x0/0xea
  [<ffffffff80247e6a>] kthread+0x4e/0x7c
  [<ffffffff8020c289>] child_rip+0xa/0x11
  [<ffffffff80247e1c>] ? kthread+0x0/0x7c
  [<ffffffff8020c27f>] ? child_rip+0x0/0x11


Code: 98 48 8b 94 c7 e0 00 00 00 48 8b 32 44 8b 6a 18 48 85 f6 75 13 49 
89 d0 44 89 e6 83 ca ff e8 b3 f8 ff ff 48 89 c6 eb 0a 8b 42 14 <48> 8b 
04 c6 48 89 02 53 9d 31 c0 41 c1 ec 0f 48 85 f6 0f 95 c0
RIP  [<ffffffff80290632>] kmem_cache_alloc+0x50/0x81
  RSP <ffff88007fadfcb0>
CR2: 0000000001a40ca0
---[ end trace a3dee77ef1628c0f ]---



#git log:
commit c010b2f76c3032e48097a6eef291d8593d5d79a6
Merge: 6069fb2... 521c4d9...
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue Jul 22 19:09:51 2008 -0700


Its a Thinkpad T60 Notebook,
Core2Duo T7200 CPU
E1000 pcie nic, e1000e is built in
gentoo amd64
gcc (GCC) 4.1.2 (Gentoo 4.1.2 p1.1)





-- 
3rd Law of Computing:
         Anything that can go wr
fortune: Segmentation violation -- Core dumped
