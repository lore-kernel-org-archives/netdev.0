From: Dave Jones <davej@redhat.com>
Subject: use-after-free in usbnet
Date: Mon, 19 Mar 2012 11:12:24 -0400
Message-ID: <20120319151224.GA16031@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376Ab2CSPM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 11:12:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've had two reports of this use after free in Fedora now recently..



general protection fault: 0000 [#1] SMP 
CPU 0 
Modules linked in: cdc_ether usbnet mii cdc_wdm cdc_acm fuse ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_CHECKSUM lockd iptable_mangle sunrpc bridge stp llc be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi arc4 uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev v4l2_compat_ioctl32 media microcode iwlwifi i2c_i801 snd_hda_codec_conexant snd_hda_intel mac80211 snd_hda_codec snd_hwdep iTCO_wdt iTCO_vendor_support snd_pcm cfg80211 snd_page_alloc snd_timer e1000e thinkpad_acpi snd soundcore rfkill vhost_net tun macvtap macvlan kvm_intel kvm uin
 put xts gf128mul dm_crypt sdhci_pci sdhci mmc_core wmi i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
Pid: 632, comm: NetworkManager Not tainted 3.3.0-0.rc7.git0.3.fc17.x86_64 #1 LENOVO 2808D9G/2808D9G
RIP: 0010:[<ffffffff8131f671>]  [<ffffffff8131f671>] kobject_put+0x11/0x60
RSP: 0018:ffff88021424d4e8  EFLAGS: 00010206
RAX: 0000000000000000 RBX: 6b6b6b6b6b6b6c03 RCX: 0000000000000006
RDX: 0000000000000990 RSI: ffff8802165108d0 RDI: 6b6b6b6b6b6b6c03
RBP: ffff88021424d4f8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff8801be9eb0c0
R13: 00000000ffffff98 R14: ffff8801d88e4010 R15: 000000000000002f
FS:  00007fde3f65c840(0000) GS:ffff880232e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ffe21c41000 CR3: 00000002167ed000 CR4: 00000000000406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process NetworkManager (pid: 632, threadinfo ffff88021424c000, task ffff880216510000)
Stack:
 ffff88021424d4f8 0000000000000000 ffff88021424d508 ffffffff8140d9f7
 ffff88021424d518 ffffffff8147e78a ffff88021424d548 ffffffff81487ef0
 ffff88021424d538 ffff8801bbfbf3c0 ffff8801d88e4028 ffff8801be9eb0c0
Call Trace:
 [<ffffffff8140d9f7>] put_device+0x17/0x20
 [<ffffffff8147e78a>] usb_put_dev+0x1a/0x20
 [<ffffffff81487ef0>] usb_hcd_unlink_urb+0x70/0x100
 [<ffffffff814889f6>] usb_unlink_urb+0x26/0x50
 [<ffffffffa06c68bb>] unlink_urbs.isra.15+0x7b/0xd0 [usbnet]
 [<ffffffffa06c6a82>] usbnet_terminate_urbs+0x172/0x290 [usbnet]
 [<ffffffff8169aedd>] ? __mutex_unlock_slowpath+0xdd/0x180
 [<ffffffff8109c2b0>] ? try_to_wake_up+0x340/0x340
 [<ffffffff8108b0c7>] ? add_wait_queue+0x27/0x60
 [<ffffffffa06c89f8>] usbnet_stop+0x108/0x1a0 [usbnet]
 [<ffffffff81559f1d>] __dev_close_many+0x9d/0xf0
 [<ffffffff81559fab>] __dev_close+0x3b/0x60
 [<ffffffff81563af1>] __dev_change_flags+0xa1/0x180
 [<ffffffff81563c88>] dev_change_flags+0x28/0x70
 [<ffffffff8157261a>] do_setlink+0x34a/0x9d0
 [<ffffffff8133e881>] ? nla_parse+0x31/0xe0
 [<ffffffff812bfe5e>] ? avc_has_perm_noaudit+0x4e/0x530
 [<ffffffff815736ae>] rtnl_newlink+0x37e/0x560
 [<ffffffff812c0d19>] ? selinux_capable+0x39/0x50
 [<ffffffff8169a100>] ? mutex_lock_nested+0x270/0x3a0
 [<ffffffff812bd158>] ? security_capable+0x18/0x20
 [<ffffffff81572f04>] rtnetlink_rcv_msg+0x114/0x2e0
 [<ffffffff815707d7>] ? rtnl_lock+0x17/0x20
 [<ffffffff81572df0>] ? __rtnl_unlock+0x20/0x20
 [<ffffffff8158f291>] netlink_rcv_skb+0xa1/0xb0
 [<ffffffff81570805>] rtnetlink_rcv+0x25/0x40
 [<ffffffff8158ebdd>] netlink_unicast+0x19d/0x1f0
 [<ffffffff8158ef0b>] netlink_sendmsg+0x2db/0x360
 [<ffffffff8154b6fd>] ? sock_update_netprioidx+0x6d/0x250
 [<ffffffff81544d58>] sock_sendmsg+0xf8/0x130
 [<ffffffff810cc45f>] ? lock_release_non_nested+0x2ef/0x330
 [<ffffffff81174105>] ? might_fault+0xa5/0xb0
 [<ffffffff811740bc>] ? might_fault+0x5c/0xb0
 [<ffffffff815542c6>] ? verify_iovec+0x56/0xd0
 [<ffffffff8154521e>] __sys_sendmsg+0x42e/0x440
 [<ffffffff810210f9>] ? sched_clock+0x9/0x10
 [<ffffffff810a2a35>] ? sched_clock_local+0x25/0xa0
 [<ffffffff810a2be8>] ? sched_clock_cpu+0xa8/0x120
 [<ffffffff810c706d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff810a2ccf>] ? local_clock+0x6f/0x80
 [<ffffffff811bd2e0>] ? fget_light+0xf0/0x4a0
 [<ffffffff811bd252>] ? fget_light+0x62/0x4a0
 [<ffffffff811bde14>] ? fput+0x1e4/0x280
 [<ffffffff81547ce9>] sys_sendmsg+0x49/0x90
 [<ffffffff816a6b69>] system_call_fastpath+0x16/0x1b
Code: 01 00 e9 10 ff ff ff 0f 1f 00 55 48 83 ef 38 48 89 e5 e8 43 fe ff ff 5d c3 90 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 85 ff 74 1a <f6> 47 3c 01 74 21 f0 83 6b 38 01 0f 94 c0 84 c0 74 08 48 89 df 
RIP  [<ffffffff8131f671>] kobject_put+0x11/0x60
 RSP <ffff88021424d4e8>
