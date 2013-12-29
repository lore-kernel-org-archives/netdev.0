From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [WARNING net-next] from ixgbe_configure
Date: Sun, 29 Dec 2013 13:15:45 -0800
Message-ID: <20131229131545.5a8773c9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:58835 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab3L2VPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 16:15:49 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so10914873pab.6
        for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 13:15:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Warning with current net-next from ixgbe_configure calling 
netdev_all_upper_get_next_dev_rcu without RCU read lock held.


[    4.717512] r8169 0000:03:00.0 eth0: link down
[    4.717581] r8169 0000:03:00.0 eth0: link down
[    4.717590] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    6.722390] r8169 0000:03:00.0 eth0: link up
[    6.722428] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    9.833968] ------------[ cut here ]------------
[    9.833976] WARNING: CPU: 5 PID: 2173 at net/core/dev.c:4448 netdev_all_upper_get_next_dev_rcu+0x6b/0xa0()
[    9.833977] Modules linked in: loop hid_belkin hid_generic usbhid hid x86_pkg_temp_thermal ghash_clmulni_intel microcode psmouse serio_raw pcspkr evdev i2c_i801 i915 drm_kms_helper drm video i2c_algo_bit i2c_core processor button btrfs xor lzo_compress raid6_pq dm_mod skge r8169 mii ixgbe thermal dca ptp pps_core mdio
[    9.833997] CPU: 5 PID: 2173 Comm: ip Tainted: G        W    3.13.0-rc4-net-next+ #57
[    9.833998] Hardware name: System manufacturer System Product Name/P8Z77-V LX, BIOS 0801 07/17/2012
[    9.834000]  0000000000000009 ffff88040cc33608 ffffffff8159cddb 0000000000000006
[    9.834003]  0000000000000000 ffff88040cc33648 ffffffff81093512 ffff880409b2f680
[    9.834005]  ffff88040cc336a0 ffff880409aa0000 0000000000000002 ffff880409aa0f18
[    9.834008] Call Trace:
[    9.834012]  [<ffffffff8159cddb>] dump_stack+0x4e/0x68
[    9.834016]  [<ffffffff81093512>] warn_slowpath_common+0x82/0xb0
[    9.834019]  [<ffffffff81093555>] warn_slowpath_null+0x15/0x20
[    9.834022]  [<ffffffff814a71eb>] netdev_all_upper_get_next_dev_rcu+0x6b/0xa0
[    9.834027]  [<ffffffffa003ea2b>] ixgbe_configure+0x7eb/0x900 [ixgbe]
[    9.834031]  [<ffffffffa0040490>] ixgbe_open+0xc0/0x550 [ixgbe]
[    9.834035]  [<ffffffff810b85c1>] ? raw_notifier_call_chain+0x11/0x20
[    9.834037]  [<ffffffff814a423b>] ? call_netdevice_notifiers_info+0x3b/0x70
[    9.834040]  [<ffffffff814ac3de>] __dev_open+0xae/0x130
[    9.834042]  [<ffffffff814ac6e7>] __dev_change_flags+0xa7/0x190
[    9.834044]  [<ffffffff814ac80b>] dev_change_flags+0x2b/0x70
[    9.834048]  [<ffffffff81554e49>] ? inet6_fill_ifla6_attrs+0x3c9/0x400
[    9.834050]  [<ffffffff814bb1b1>] do_setlink+0x351/0x950
[    9.834053]  [<ffffffff81554e95>] ? inet6_fill_link_af+0x15/0x30
[    9.834056]  [<ffffffff812c6151>] ? nla_parse+0x31/0xe0
[    9.834058]  [<ffffffff814bbe79>] rtnl_newlink+0x359/0x570
[    9.834061]  [<ffffffff814bb97f>] rtnetlink_rcv_msg+0x9f/0x240
[    9.834064]  [<ffffffff810d97dd>] ? trace_hardirqs_on+0xd/0x10
[    9.834066]  [<ffffffff814b7fd2>] ? rtnl_lock+0x12/0x20
[    9.834069]  [<ffffffff814bb8e0>] ? __rtnl_unlock+0x20/0x20
[    9.834072]  [<ffffffff814d6019>] netlink_rcv_skb+0xa9/0xc0
[    9.834074]  [<ffffffff814b8000>] rtnetlink_rcv+0x20/0x30
[    9.834077]  [<ffffffff814d559d>] netlink_unicast+0xfd/0x180
[    9.834080]  [<ffffffff814d5949>] netlink_sendmsg+0x329/0x770
[    9.834083]  [<ffffffff81155687>] ? might_fault+0x57/0xb0
[    9.834086]  [<ffffffff81490527>] sock_sendmsg+0x97/0xc0
[    9.834089]  [<ffffffff811556d0>] ? might_fault+0xa0/0xb0
[    9.834091]  [<ffffffff81155687>] ? might_fault+0x57/0xb0
[    9.834093]  [<ffffffff8149dfc6>] ? verify_iovec+0x56/0xd0
[    9.834095]  [<ffffffff81490911>] ___sys_sendmsg+0x3c1/0x3d0
[    9.834098]  [<ffffffff810d3a0e>] ? up_read+0x1e/0x40
[    9.834101]  [<ffffffff8107a7fc>] ? __do_page_fault+0x1ec/0x4d0
[    9.834104]  [<ffffffff8117e7e5>] ? kmem_cache_alloc+0x135/0x180
[    9.834107]  [<ffffffff810d97dd>] ? trace_hardirqs_on+0xd/0x10
[    9.834110]  [<ffffffff811602db>] ? do_brk+0x1bb/0x320
[    9.834113]  [<ffffffff81491734>] __sys_sendmsg+0x44/0x80
[    9.834115]  [<ffffffff8149177d>] SyS_sendmsg+0xd/0x20
[    9.834118]  [<ffffffff815a5239>] system_call_fastpath+0x16/0x1b
[    9.834120] ---[ end trace 868dd8e35bbcd629 ]---
[    9.890630] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
