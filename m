From: Norbert Preining <preining@logic.at>
Subject: Re: 2.6.29-rc1-wl gives WARNING on ich8lan
Date: Sun, 18 Jan 2009 22:39:53 +0100
Message-ID: <20090118213953.GH10583@gamma.logic.tuwien.ac.at>
References: <20090114231546.GI1457@gamma.logic.tuwien.ac.at> <20090114222550.80fb1bb2.akpm@linux-foundation.org> <17975dc10901151417o4c5affbdrd7ef29818c8f5008@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: dave graham <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.logic.tuwien.ac.at ([128.130.175.19]:56961 "EHLO
	mx.logic.tuwien.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbZARVj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 16:39:58 -0500
Content-Disposition: inline
In-Reply-To: <17975dc10901151417o4c5affbdrd7ef29818c8f5008@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 15 Jan 2009, dave graham wrote:
> I'll monitor reports up at keneloops daily, and when I've got 5 or more, I
> can quickly move the WARN to debug-only code, so reports will soon

If you need one more, here it is, a bit different to the previous one,
at least for my eyes.

[  544.804215] ------------[ cut here ]------------
[  544.804225] WARNING: at drivers/net/e1000e/ich8lan.c:412 e1000_acquire_swflag_ich8lan+0x35/0xcc()
[  544.804231] Hardware name: VGN-Z11VN_B
[  544.804234] e1000e mutex contention. Owned by pid 8
[  544.804238] Modules linked in: binfmt_misc rfcomm l2cap kvm isofs zlib_inflate vfat fat fuse dm_crypt dm_mod firewire_sbp2 loop arc4 iwlagn iwlcore joydev rfkill firewire_ohci firewire_core crc_itu_t mac80211 btusb cfg80211 sony_laptop video tpm_infineon backlight
[  544.804294] Pid: 3748, comm: ifplugd Not tainted 2.6.29-rc1-wl #1
[  544.804299] Call Trace:
[  544.804310]  [<ffffffff80236441>] warn_slowpath+0xd8/0x112
[  544.804320]  [<ffffffff805105e0>] schedule_hrtimeout_range+0xa2/0xf3
[  544.804329]  [<ffffffff8024891a>] remove_wait_queue+0x12/0x41
[  544.804337]  [<ffffffff8051152f>] _spin_unlock_irqrestore+0x31/0x3d
[  544.804345]  [<ffffffff80296302>] do_select+0x51d/0x53e
[  544.804353]  [<ffffffff802967e6>] __pollwait+0x0/0xcd
[  544.804360]  [<ffffffff802968b3>] pollwake+0x0/0x49
[  544.804368]  [<ffffffff803a5872>] e1000e_read_phy_reg_mdic+0x48/0x7a
[  544.804375]  [<ffffffff803a12a4>] e1000_acquire_swflag_ich8lan+0x35/0xcc
[  544.804382]  [<ffffffff803a5c0b>] e1000e_read_phy_reg_bm+0x39/0xbe
[  544.804389]  [<ffffffff803a5ee7>] e1000e_phy_has_link_generic+0x50/0xcc
[  544.804396]  [<ffffffff803a4d25>] e1000e_check_for_copper_link+0x24/0x86
[  544.804405]  [<ffffffff8022c437>] set_next_entity+0x34/0x56
[  544.804412]  [<ffffffff803aa186>] e1000_has_link+0x40/0xc1
[  544.804419]  [<ffffffff805114f1>] _spin_unlock_irq+0x30/0x3d
[  544.804426]  [<ffffffff803a929a>] e1000_get_link+0x10/0x16
[  544.804435]  [<ffffffff8049f3f7>] ethtool_get_value+0x1f/0x42
[  544.804442]  [<ffffffff8023d507>] capable+0x3b/0x5a
[  544.804448]  [<ffffffff8049f865>] dev_ethtool+0x446/0x106d
[  544.804455]  [<ffffffff8022c1df>] check_preempt_wakeup+0x102/0x148
[  544.804463]  [<ffffffff8051152f>] _spin_unlock_irqrestore+0x31/0x3d
[  544.804470]  [<ffffffff802324f9>] try_to_wake_up+0x168/0x17a
[  544.804488]  [<ffffffff805115e6>] _spin_unlock+0x2f/0x3b
[  544.804495]  [<ffffffff805103d0>] __mutex_unlock_slowpath+0x31/0x3c
[  544.804502]  [<ffffffff8049b6cf>] dev_name_hash+0x19/0x5e
[  544.804509]  [<ffffffff8049eae7>] dev_ioctl+0x4bf/0x5fb
[  544.804519]  [<ffffffff8048ffc4>] sockfd_lookup_light+0x1a/0x51
[  544.804528]  [<ffffffff80268d83>] get_pageblock_migratetype+0x17/0x18
[  544.804535]  [<ffffffff8048ff34>] sock_ioctl+0x1ec/0x1f6
[  544.804542]  [<ffffffff80294862>] vfs_ioctl+0x21/0x6c
[  544.804548]  [<ffffffff80294ce6>] do_vfs_ioctl+0x439/0x472
[  544.804555]  [<ffffffff80294d5c>] sys_ioctl+0x3d/0x5c
[  544.804561]  [<ffffffff80294d21>] sys_ioctl+0x2/0x5c
[  544.804569]  [<ffffffff8020b71b>] system_call_fastpath+0x16/0x1b
[  544.804574] ---[ end trace c1d34b6f12f69ad8 ]---

Best wishes

Norbert

-------------------------------------------------------------------------------
Dr. Norbert Preining <preining@logic.at>        Vienna University of Technology
Debian Developer <preining@debian.org>                         Debian TeX Group
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C5 B094
-------------------------------------------------------------------------------
Another world, another day, another dawn.
                 --- Douglas Adams, The Hitchhikers Guide to the Galaxy
