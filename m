From: Ben Greear <greearb@candelatech.com>
Subject: kmemleak reports in kernel 3.9.5+
Date: Mon, 10 Jun 2013 11:22:58 -0700
Message-ID: <51B61982.2050903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33626 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab3FJSXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 14:23:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had a system go OOM while doing lots of wireless
stations.  (System had 8GB of RAM, so I suspect a leak).

I enabled kmemleak in a 3.9.5 (plus some local patches) and
I see the entries below.  Any idea if these are real or not?

unreferenced object 0xffff880212281c80 (size 128):
   comm "systemd", pid 1, jiffies 4294682684 (age 1159.517s)
   hex dump (first 32 bytes):
     60 39 27 12 02 88 ff ff 00 02 20 00 00 00 ad de  `9'....... .....
     10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d605>] __kmalloc+0xf9/0x122
     [<ffffffff8154946d>] kzalloc.clone.0+0xe/0x10
     [<ffffffff81549494>] fib_default_rule_add+0x25/0x7a
     [<ffffffffa014f5a9>] ip6mr_net_init+0x7e/0x118 [ipv6]
     [<ffffffff8152c992>] ops_init+0xd6/0xf7
     [<ffffffff8152cb51>] register_pernet_operations+0xc2/0x16b
     [<ffffffff8152cc87>] register_pernet_subsys+0x2e/0x47
     [<ffffffffa016db69>] 0xffffffffa016db69
     [<ffffffffa016d109>] 0xffffffffa016d109
     [<ffffffff8100207f>] do_one_initcall+0x7f/0x13e
     [<ffffffff810f3985>] do_init_module+0x44/0x18f
     [<ffffffff810f5da7>] load_module+0x14d1/0x168e
     [<ffffffff810f6114>] sys_init_module+0xfd/0x101
     [<ffffffff815f6599>] system_call_fastpath+0x16/0x1b
unreferenced object 0xffff880218ed92b0 (size 40):
   comm "gnome-session", pid 934, jiffies 4294693971 (age 1148.267s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 97 41 8b 01 88 ff ff  ..........A.....
     02 00 00 00 00 00 00 00 20 44 46 08 00 ea ff ff  ........ DF.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118e888>] kmem_cache_free+0xbe/0x15d
     [<ffffffff81175d98>] unlink_anon_vmas+0x9f/0x154
unreferenced object 0xffff88021716f870 (size 40):
   comm "ip", pid 3146, jiffies 4294741842 (age 1100.453s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 c0 dc 37 ee 01 88 ff ff  ..........7.....
     01 00 00 00 00 00 00 00 88 35 0c e4 01 88 ff ff  .........5......
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810a70df>] init_timer_key+0x2e/0xb3
     [<ffffffff81521dcb>] sock_init_data+0x69/0x1ed
     [<ffffffff815551a5>] __netlink_create+0x4f/0xb5
     [<ffffffff815552fd>] netlink_create+0xf2/0x148
     [<ffffffff8151ec54>] __sock_create+0x135/0x1be
     [<ffffffff8151ed33>] sock_create+0x30/0x32
     [<ffffffff81520517>] sys_socket+0x2f/0x98
     [<ffffffff815f6599>] system_call_fastpath+0x16/0x1b
     [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff8801ebeb4450 (size 40):
   comm "bash", pid 3200, jiffies 4294742742 (age 1099.584s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 c0 e5 91 f1 01 88 ff ff  ................
     01 00 00 00 00 00 00 00 40 4d 3d e4 01 88 ff ff  ........@M=.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118e888>] kmem_cache_free+0xbe/0x15d
     [<ffffffff81175d98>] unlink_anon_vmas+0x9f/0x154
unreferenced object 0xffff8801f191e5c0 (size 40):
   comm "clock-applet", pid 3100, jiffies 4294742818 (age 1099.508s)
   hex dump (first 32 bytes):
     50 44 eb eb 01 88 ff ff 70 f8 bb 9a 01 88 ff ff  PD......p.......
     01 00 00 00 00 00 00 00 58 45 3d e4 01 88 ff ff  ........XE=.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118e888>] kmem_cache_free+0xbe/0x15d
     [<ffffffff811a51c6>] final_putname+0x38/0x3c
unreferenced object 0xffff8801ed2468a0 (size 40):
   comm "wnck-applet", pid 3093, jiffies 4294742922 (age 1099.404s)
   hex dump (first 32 bytes):
     c0 3c b3 f1 01 88 ff ff 80 19 6a 82 ff ff ff ff  .<........j.....
     01 00 00 00 00 00 00 00 c8 74 31 e4 01 88 ff ff  .........t1.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118daf5>] kfree+0xdd/0x158
     [<ffffffff815262b9>] skb_free_head+0x67/0x69
unreferenced object 0xffff8801f193cb80 (size 40):
   comm "dbus-daemon", pid 1377, jiffies 4294743052 (age 1099.304s)
   hex dump (first 32 bytes):
     60 0e 39 ee 01 88 ff ff 70 e1 75 c6 01 88 ff ff  `.9.....p.u.....
     01 00 00 00 00 00 00 00 a0 2d 01 e5 01 88 ff ff  .........-......
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118e888>] kmem_cache_free+0xbe/0x15d
     [<ffffffff811a51c6>] final_putname+0x38/0x3c
unreferenced object 0xffff8801f1b33cc0 (size 40):
   comm "wpa_cli", pid 3221, jiffies 4294743135 (age 1099.221s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 a0 68 24 ed 01 88 ff ff  .........h$.....
     01 00 00 00 00 00 00 00 b0 7c 31 e4 01 88 ff ff  .........|1.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff8119be2b>] file_free+0x31/0x35
     [<ffffffff8119be61>] put_filp+0x32/0x36
     [<ffffffff811a6bf1>] path_openat+0x340/0x379
     [<ffffffff811a6d39>] do_filp_open+0x3d/0x89
     [<ffffffff81199346>] do_sys_open+0x72/0x104
     [<ffffffff8119940f>] sys_open+0x21/0x23
unreferenced object 0xffff8801ee390e60 (size 40):
   comm "evolution-alarm", pid 3011, jiffies 4294743335 (age 1099.023s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 80 cb 93 f1 01 88 ff ff  ................
     01 00 00 00 00 00 00 00 b8 25 01 e5 01 88 ff ff  .........%......
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118e888>] kmem_cache_free+0xbe/0x15d
     [<ffffffff811a51c6>] final_putname+0x38/0x3c
unreferenced object 0xffff880216e7ca10 (size 40):
   comm "metacity", pid 2810, jiffies 4294744465 (age 1097.923s)
   hex dump (first 32 bytes):
     30 fe 97 ee 01 88 ff ff 80 6b 5c 82 ff ff ff ff  0........k\.....
     01 00 00 00 00 00 00 00 70 3d 15 e5 01 88 ff ff  ........p=......
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118e888>] kmem_cache_free+0xbe/0x15d
     [<ffffffff81527493>] __kfree_skb+0x7d/0x82
unreferenced object 0xffff8801ee97fe30 (size 40):
   comm "pool", pid 3081, jiffies 4294744513 (age 1097.875s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 10 ca e7 16 02 88 ff ff  ................
     01 00 00 00 00 00 00 00 88 35 15 e5 01 88 ff ff  .........5......
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118e888>] kmem_cache_free+0xbe/0x15d
     [<ffffffff811a51c6>] final_putname+0x38/0x3c

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
