From: Josh Boyer <jwboyer@redhat.com>
Subject: assert_cfg80211_lock warning with Linux v3.5-8833-g2d53492
Date: Wed, 1 Aug 2012 09:12:33 -0400
Message-ID: <20120801131232.GA1785@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Brett Rudley <brudley@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab2HANMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 09:12:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

With the latest Linus tree as of this morning, I'm getting the warning
below continuously.  I've attached the first two instances of it.  The
machine is a Dell XPS 8300 with a BCM4313 wireless chip in it.
Userspace is Fedora 17 and NetworkManager is controlling things though I
don't have it set to connect to any networks.

Please let me know if you've seen this before and if there is more
information I can provide.

josh

[   15.587855] brcmsmac bcma0:0: mfg 4bf core 812 rev 24 class 0 irq 16
[   15.636460] cfg80211: World regulatory domain updated:
[   15.636462] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[   15.636463] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   15.636465] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[   15.636466] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[   15.636467] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   15.636468] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   15.703640] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   15.957344] ALSA sound/pci/hda/hda_intel.c:2745 Using COMBO position fix
[   15.957532] snd_hda_intel 0000:00:1b.0: irq 46 for MSI/MSI-X
[   16.253325] cfg80211: Calling CRDA for country: US
[   16.271042] cfg80211: Regulatory domain changed to country: US
[   16.271045] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[   16.271048] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[   16.271051] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[   16.271053] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   16.271055] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   16.271057] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   16.271060] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)

<snip a bunch of ALSA/input stuff>

[   21.762086] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   25.698788] Bridge firewalling registered
[   25.746690] device virbr0-nic entered promiscuous mode
[   26.573028] ------------[ cut here ]------------
[   26.573042] WARNING: at net/wireless/core.h:125 assert_cfg80211_lock.part.8+0x15/0x17 [cfg80211]()
[   26.573045] Hardware name: XPS 8300  
[   26.573046] Modules linked in: xt_CHECKSUM iptable_mangle bridge stp llc ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_defrag_ipv4 xt_state nf_conntrack ib_iser rdma_cm ib_addr ip6table_filter tpm_bios ip6_tables iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel arc4 brcmsmac snd_hda_codec cordic brcmutil snd_hwdep mac80211 snd_pcm snd_page_alloc snd_timer cfg80211 snd coretemp rfkill serio_raw i2c_i801 soundcore lpc_ich bcma dcdbas microcode mfd_core mei vhost_net tun macvtap macvlan kvm_intel nfsd kvm auth_rpcgss nfs_acl lockd uinput crc32c_intel ghash_clmulni_intel broadcom tg3 usb_storage uas radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core sunrpc be2iscsi bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi li
 biscsi_tcp qla4xxx iscsi_boot_sysfs libiscsi scsi_transport_iscsi
[   26.573143] Pid: 757, comm: NetworkManager Not tainted 3.6.0-0.rc0.git8.1.fc18.x86_64 #1
[   26.573145] Call Trace:
[   26.573153]  [<ffffffff8106782f>] warn_slowpath_common+0x7f/0xc0
[   26.573159]  [<ffffffff8106788a>] warn_slowpath_null+0x1a/0x20
[   26.573170]  [<ffffffffa04c730d>] assert_cfg80211_lock.part.8+0x15/0x17 [cfg80211]
[   26.573181]  [<ffffffffa04a8dcb>] freq_reg_info+0x6b/0x80 [cfg80211]
[   26.573193]  [<ffffffffa06b6c99>] brcms_c_channel_set_chanspec+0x2c9/0x350 [brcmsmac]
[   26.573204]  [<ffffffffa06b7330>] brcms_c_set_phy_chanspec+0x30/0x70 [brcmsmac]
[   26.573216]  [<ffffffffa06c1a45>] brcms_c_init+0xb25/0x12f0 [brcmsmac]
[   26.573225]  [<ffffffffa047e61c>] ? bcma_host_pci_write32+0x3c/0x50 [bcma]
[   26.573235]  [<ffffffffa06b322c>] brcms_init+0x5c/0x70 [brcmsmac]
[   26.573247]  [<ffffffffa06bff5e>] brcms_c_up+0x23e/0x520 [brcmsmac]
[   26.573290]  [<ffffffffa06b34a9>] brcms_up+0x29/0x30 [brcmsmac]
[   26.573299]  [<ffffffffa06b3d0d>] brcms_ops_start+0x6d/0xe0 [brcmsmac]
[   26.573324]  [<ffffffffa0626a01>] ieee80211_do_open+0x2e1/0x11b0 [mac80211]
[   26.573342]  [<ffffffffa062793d>] ieee80211_open+0x6d/0x80 [mac80211]
[   26.573349]  [<ffffffff8158fecf>] __dev_open+0x8f/0xf0
[   26.573357]  [<ffffffff81590191>] __dev_change_flags+0xa1/0x180
[   26.573363]  [<ffffffff81590328>] dev_change_flags+0x28/0x70
[   26.573371]  [<ffffffff8159e278>] do_setlink+0x378/0xa00
[   26.573380]  [<ffffffff810ac5a5>] ? sched_clock_cpu+0xc5/0x120
[   26.573386]  [<ffffffff81021db3>] ? native_sched_clock+0x13/0x80
[   26.573392]  [<ffffffff81359a51>] ? nla_parse+0x31/0xe0
[   26.573398]  [<ffffffff815a09ae>] rtnl_newlink+0x37e/0x560
[   26.573407]  [<ffffffff812d54a9>] ? selinux_capable+0x39/0x50
[   26.573412]  [<ffffffff812d1a58>] ? security_capable+0x18/0x20
[   26.573418]  [<ffffffff815a01d4>] rtnetlink_rcv_msg+0x114/0x2f0
[   26.573424]  [<ffffffff8159d047>] ? rtnl_lock+0x17/0x20
[   26.573431]  [<ffffffff8159d047>] ? rtnl_lock+0x17/0x20
[   26.573440]  [<ffffffff815a00c0>] ? __rtnl_unlock+0x20/0x20
[   26.573447]  [<ffffffff815bbf11>] netlink_rcv_skb+0xa1/0xb0
[   26.573454]  [<ffffffff8159d075>] rtnetlink_rcv+0x25/0x40
[   26.573460]  [<ffffffff815bb89d>] netlink_unicast+0x19d/0x220
[   26.573466]  [<ffffffff815bbbfb>] netlink_sendmsg+0x2db/0x360
[   26.573474]  [<ffffffff81576268>] ? sock_update_classid+0x148/0x2e0
[   26.573480]  [<ffffffff8156fd7c>] sock_sendmsg+0xbc/0xf0
[   26.573487]  [<ffffffff810ac66f>] ? local_clock+0x6f/0x80
[   26.573495]  [<ffffffff810d5a17>] ? lock_release_non_nested+0x2f7/0x330
[   26.573501]  [<ffffffff81570dec>] __sys_sendmsg+0x3ac/0x3c0
[   26.573504]  [<ffffffff81021db3>] ? native_sched_clock+0x13/0x80
[   26.573508]  [<ffffffff81021e29>] ? sched_clock+0x9/0x10
[   26.573511]  [<ffffffff810ac5a5>] ? sched_clock_cpu+0xc5/0x120
[   26.573515]  [<ffffffff810d05ad>] ? trace_hardirqs_off+0xd/0x10
[   26.573519]  [<ffffffff810ac66f>] ? local_clock+0x6f/0x80
[   26.573523]  [<ffffffff811c6939>] ? fget_light+0xf9/0x520
[   26.573526]  [<ffffffff811c687c>] ? fget_light+0x3c/0x520
[   26.573530]  [<ffffffff815737d9>] sys_sendmsg+0x49/0x90
[   26.573537]  [<ffffffff816d8429>] system_call_fastpath+0x16/0x1b
[   26.573541] ---[ end trace 9edc8e6bb8e18f3f ]---
[   26.575489] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[   26.575571] ieee80211 phy0: brcms_ops_config: change power-save mode: false (implement)
[   26.576055] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   26.729219] tg3 0000:03:00.0: irq 48 for MSI/MSI-X
[   26.746776] IPv6: ADDRCONF(NETDEV_UP): p3p1: link is not ready
[   27.084202] tg3 0000:03:00.0: p3p1: Link is down
[   27.089383] IPv6: ADDRCONF(NETDEV_UP): virbr0: link is not ready
[   28.413963] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   28.430879] NFSD: starting 90-second grace period
[   28.666424] ------------[ cut here ]------------
[   28.666441] WARNING: at net/wireless/core.h:125 assert_cfg80211_lock.part.8+0x15/0x17 [cfg80211]()
[   28.666451] Hardware name: XPS 8300  
[   28.666451] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle bridge stp llc ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_defrag_ipv4 xt_state nf_conntrack ib_iser rdma_cm ib_addr ip6table_filter tpm_bios ip6_tables iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel arc4 brcmsmac snd_hda_codec cordic brcmutil snd_hwdep mac80211 snd_pcm snd_page_alloc snd_timer cfg80211 snd coretemp rfkill serio_raw i2c_i801 soundcore lpc_ich bcma dcdbas microcode mfd_core mei vhost_net tun macvtap macvlan kvm_intel nfsd kvm auth_rpcgss nfs_acl lockd uinput crc32c_intel ghash_clmulni_intel broadcom tg3 usb_storage uas radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core sunrpc be2iscsi bnx2i cnic uio cxgb4i c
 xgb4 cxgb3i cxgb3 mdio libcxgbi libiscsi_tcp qla4xxx iscsi_boot_sysfs libiscsi scsi_transport_iscsi
[   28.666504] Pid: 109, comm: kworker/u:5 Tainted: G        W    3.6.0-0.rc0.git8.1.fc18.x86_64 #1
[   28.666505] Call Trace:
[   28.666510]  [<ffffffff8106782f>] warn_slowpath_common+0x7f/0xc0
[   28.666514]  [<ffffffff8106788a>] warn_slowpath_null+0x1a/0x20
[   28.666519]  [<ffffffffa04c730d>] assert_cfg80211_lock.part.8+0x15/0x17 [cfg80211]
[   28.666525]  [<ffffffffa04a8dcb>] freq_reg_info+0x6b/0x80 [cfg80211]
[   28.666531]  [<ffffffffa06b6c99>] brcms_c_channel_set_chanspec+0x2c9/0x350 [brcmsmac]
[   28.666537]  [<ffffffffa06b7330>] brcms_c_set_phy_chanspec+0x30/0x70 [brcmsmac]
[   28.666542]  [<ffffffffa06baf71>] brcms_c_set_chanspec+0xa1/0x1d0 [brcmsmac]
[   28.666548]  [<ffffffffa06bcb1e>] brcms_c_set_channel+0x11e/0x140 [brcmsmac]
[   28.666552]  [<ffffffffa06b23c8>] brcms_ops_config+0x108/0x1f0 [brcmsmac]
[   28.666563]  [<ffffffffa060ed92>] ieee80211_hw_config+0x142/0x3f0 [mac80211]
[   28.666572]  [<ffffffffa0619f5f>] ieee80211_scan_work+0x21f/0x7b0 [mac80211]
[   28.666576]  [<ffffffff8108bdef>] process_one_work+0x20f/0x760
[   28.666578]  [<ffffffff8108bd87>] ? process_one_work+0x1a7/0x760
[   28.666580]  [<ffffffff8108c7ce>] ? worker_thread+0x21e/0x450
[   28.666587]  [<ffffffffa0619d40>] ? ieee80211_run_deferred_scan+0x120/0x120 [mac80211]
[   28.666592]  [<ffffffff8108c70e>] worker_thread+0x15e/0x450
[   28.666595]  [<ffffffff8108c5b0>] ? rescuer_thread+0x230/0x230
[   28.666597]  [<ffffffff81092527>] kthread+0xb7/0xc0
[   28.666600]  [<ffffffff816d9604>] kernel_thread_helper+0x4/0x10
[   28.666603]  [<ffffffff816cf970>] ? retint_restore_args+0x13/0x13
[   28.666605]  [<ffffffff81092470>] ? __init_kthread_worker+0x70/0x70
[   28.666607]  [<ffffffff816d9600>] ? gs_change+0x13/0x13
[   28.666608] ---[ end trace 9edc8e6bb8e18f40 ]---
