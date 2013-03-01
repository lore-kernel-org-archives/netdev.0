From: Yinghai Lu <yinghai@kernel.org>
Subject: hang with e1000_
Date: Fri, 1 Mar 2013 15:44:22 -0800
Message-ID: <CAE9FiQVmJ0dtrxjViGHkaHigQHiBYZvuu5=4Xn4hgS=86xq9yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

on today mainline tree.

[  529.379490] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  529.399350] swapper/0       D ffff883025294000     0     1      0 0x00000000
[  529.399726]  ffff8810274f5ab8 0000000000000046 ffffffff810b3111
ffff8810274f5fd8
[  529.424058]  ffff8810274f5fd8 0000000000004000 ffff881027578000
ffff8810274f8000
[  529.439317]  ffff8810274f59f8 0000000000000002 0000000000000282
ffff88203e40d680
[  529.439740] Call Trace:
[  529.459254]  [<ffffffff810b3111>] ? __hrtimer_start_range_ns+0x391/0x400
[  529.459610]  [<ffffffff810e95bd>] ? trace_hardirqs_on+0xd/0x10
[  529.480104]  [<ffffffff810b3111>] ? __hrtimer_start_range_ns+0x391/0x400
[  529.480482]  [<ffffffff8219535d>] schedule+0x5d/0x60
[  529.499357]  [<ffffffff8219405c>] schedule_hrtimeout_range_clock+0x10c/0x160
[  529.499710]  [<ffffffff810b2720>] ? update_rmtp+0x70/0x70
[  529.519406]  [<ffffffff810b31b4>] ? hrtimer_start_range_ns+0x14/0x20
[  529.539192]  [<ffffffff821940c3>] schedule_hrtimeout_range+0x13/0x20
[  529.539507]  [<ffffffff8109a040>] usleep_range+0x40/0x50
[  529.559225]  [<ffffffff81b33dc9>] e1000_get_cfg_done_82571+0x39/0x50
[  529.559539]  [<ffffffff81b42dc2>] e1000e_phy_hw_reset_generic+0x102/0x160
[  529.579338]  [<ffffffff81b41ac7>] e1000e_copper_link_setup_igp+0x17/0x160
[  529.579662]  [<ffffffff81b34e80>] e1000_setup_copper_link_82571+0xb0/0xd0
[  529.599457]  [<ffffffff81b3e22f>] e1000e_setup_link_generic+0xbf/0x280
[  529.621078]  [<ffffffff81b33fc2>] e1000_setup_link_82571+0x32/0x40
[  529.621365]  [<ffffffff81b54495>] e1000_open+0xc5/0x540
[  529.639395]  [<ffffffff810b4f3e>] ? __raw_notifier_call_chain+0xe/0x10
[  529.639723]  [<ffffffff81f95510>] __dev_open+0x90/0x100
[  529.659431]  [<ffffffff81f95804>] __dev_change_flags+0xd4/0x170
[  529.659723]  [<ffffffff81f95948>] dev_change_flags+0x28/0x70
[  529.679957]  [<ffffffff82ffc978>] ip_auto_config+0x193/0xea4
[  529.680270]  [<ffffffff82ffc7e5>] ? root_nfs_parse_addr+0xc0/0xc0
[  529.699378]  [<ffffffff82179e58>] ? printk+0x4d/0x4f
[  529.699668]  [<ffffffff82ffc7e5>] ? root_nfs_parse_addr+0xc0/0xc0
[  529.719381]  [<ffffffff81000254>] do_one_initcall+0x64/0x160
[  529.719692]  [<ffffffff82faf31c>] kernel_init_freeable+0x1bf/0x251
[  529.739527]  [<ffffffff82faea6c>] ? loglevel+0x31/0x31
[  529.739835]  [<ffffffff82164a70>] ? rest_init+0xc0/0xc0
[  529.759417]  [<ffffffff82164a7e>] kernel_init+0xe/0xf0
[  529.759658]  [<ffffffff8219f75c>] ret_from_fork+0x7c/0xb0
[  529.779357]  [<ffffffff82164a70>] ? rest_init+0xc0/0xc0
[  529.779592] 1 lock held by swapper/0/1:
[  529.799285]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81fa3487>]
rtnl_lock+0x17/0x20

The system is nehalem-ex 8 sockets.

Another westmere-ex 8 sockets is ok.

They have same IO add-on cards.

Thanks

Yinghai
