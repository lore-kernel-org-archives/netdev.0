From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: assert_cfg80211_lock warning with Linux v3.5-8833-g2d53492
Date: Wed, 1 Aug 2012 10:18:10 -0400
Message-ID: <20120801141810.GB27433@tuxdriver.com>
References: <20120801131232.GA1785@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Roland Vossen <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Josh Boyer <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120801131232.GA1785-8k7Gwy46GHkf7BdofF/totBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 01, 2012 at 09:12:33AM -0400, Josh Boyer wrote:

> <snip a bunch of ALSA/input stuff>
> 
> [   21.762086] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> [   25.698788] Bridge firewalling registered
> [   25.746690] device virbr0-nic entered promiscuous mode
> [   26.573028] ------------[ cut here ]------------
> [   26.573042] WARNING: at net/wireless/core.h:125 assert_cfg80211_lock.part.8+0x15/0x17 [cfg80211]()
> [   26.573045] Hardware name: XPS 8300  
> [   26.573046] Modules linked in: xt_CHECKSUM iptable_mangle bridge stp llc ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_defrag_ipv4 xt_state nf_conntrack ib_iser rdma_cm ib_addr ip6table_filter tpm_bios ip6_tables iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel arc4 brcmsmac snd_hda_codec cordic brcmutil snd_hwdep mac80211 snd_pcm snd_page_alloc snd_timer cfg80211 snd coretemp rfkill serio_raw i2c_i801 soundcore lpc_ich bcma dcdbas microcode mfd_core mei vhost_net tun macvtap macvlan kvm_intel nfsd kvm auth_rpcgss nfs_acl lockd uinput crc32c_intel ghash_clmulni_intel broadcom tg3 usb_storage uas radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core sunrpc be2iscsi bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi 
 libiscsi_tcp qla4xxx iscsi_boot_sysfs libiscsi scsi_transport_iscsi
> [   26.573143] Pid: 757, comm: NetworkManager Not tainted 3.6.0-0.rc0.git8.1.fc18.x86_64 #1
> [   26.573145] Call Trace:
> [   26.573153]  [<ffffffff8106782f>] warn_slowpath_common+0x7f/0xc0
> [   26.573159]  [<ffffffff8106788a>] warn_slowpath_null+0x1a/0x20
> [   26.573170]  [<ffffffffa04c730d>] assert_cfg80211_lock.part.8+0x15/0x17 [cfg80211]
> [   26.573181]  [<ffffffffa04a8dcb>] freq_reg_info+0x6b/0x80 [cfg80211]

brcmsmac needs to hold cfg80211_mutex before calling freq_reg_info...

It looks like those calls were added in mid-June.

> [   26.573193]  [<ffffffffa06b6c99>] brcms_c_channel_set_chanspec+0x2c9/0x350 [brcmsmac]
> [   26.573204]  [<ffffffffa06b7330>] brcms_c_set_phy_chanspec+0x30/0x70 [brcmsmac]
> [   26.573216]  [<ffffffffa06c1a45>] brcms_c_init+0xb25/0x12f0 [brcmsmac]
> [   26.573225]  [<ffffffffa047e61c>] ? bcma_host_pci_write32+0x3c/0x50 [bcma]
> [   26.573235]  [<ffffffffa06b322c>] brcms_init+0x5c/0x70 [brcmsmac]
> [   26.573247]  [<ffffffffa06bff5e>] brcms_c_up+0x23e/0x520 [brcmsmac]
> [   26.573290]  [<ffffffffa06b34a9>] brcms_up+0x29/0x30 [brcmsmac]
> [   26.573299]  [<ffffffffa06b3d0d>] brcms_ops_start+0x6d/0xe0 [brcmsmac]
> [   26.573324]  [<ffffffffa0626a01>] ieee80211_do_open+0x2e1/0x11b0 [mac80211]
> [   26.573342]  [<ffffffffa062793d>] ieee80211_open+0x6d/0x80 [mac80211]
> [   26.573349]  [<ffffffff8158fecf>] __dev_open+0x8f/0xf0
> [   26.573357]  [<ffffffff81590191>] __dev_change_flags+0xa1/0x180
> [   26.573363]  [<ffffffff81590328>] dev_change_flags+0x28/0x70
> [   26.573371]  [<ffffffff8159e278>] do_setlink+0x378/0xa00
> [   26.573380]  [<ffffffff810ac5a5>] ? sched_clock_cpu+0xc5/0x120
> [   26.573386]  [<ffffffff81021db3>] ? native_sched_clock+0x13/0x80
> [   26.573392]  [<ffffffff81359a51>] ? nla_parse+0x31/0xe0
> [   26.573398]  [<ffffffff815a09ae>] rtnl_newlink+0x37e/0x560
> [   26.573407]  [<ffffffff812d54a9>] ? selinux_capable+0x39/0x50
> [   26.573412]  [<ffffffff812d1a58>] ? security_capable+0x18/0x20
> [   26.573418]  [<ffffffff815a01d4>] rtnetlink_rcv_msg+0x114/0x2f0
> [   26.573424]  [<ffffffff8159d047>] ? rtnl_lock+0x17/0x20
> [   26.573431]  [<ffffffff8159d047>] ? rtnl_lock+0x17/0x20
> [   26.573440]  [<ffffffff815a00c0>] ? __rtnl_unlock+0x20/0x20
> [   26.573447]  [<ffffffff815bbf11>] netlink_rcv_skb+0xa1/0xb0
> [   26.573454]  [<ffffffff8159d075>] rtnetlink_rcv+0x25/0x40
> [   26.573460]  [<ffffffff815bb89d>] netlink_unicast+0x19d/0x220
> [   26.573466]  [<ffffffff815bbbfb>] netlink_sendmsg+0x2db/0x360
> [   26.573474]  [<ffffffff81576268>] ? sock_update_classid+0x148/0x2e0
> [   26.573480]  [<ffffffff8156fd7c>] sock_sendmsg+0xbc/0xf0
> [   26.573487]  [<ffffffff810ac66f>] ? local_clock+0x6f/0x80
> [   26.573495]  [<ffffffff810d5a17>] ? lock_release_non_nested+0x2f7/0x330
> [   26.573501]  [<ffffffff81570dec>] __sys_sendmsg+0x3ac/0x3c0
> [   26.573504]  [<ffffffff81021db3>] ? native_sched_clock+0x13/0x80
> [   26.573508]  [<ffffffff81021e29>] ? sched_clock+0x9/0x10
> [   26.573511]  [<ffffffff810ac5a5>] ? sched_clock_cpu+0xc5/0x120
> [   26.573515]  [<ffffffff810d05ad>] ? trace_hardirqs_off+0xd/0x10
> [   26.573519]  [<ffffffff810ac66f>] ? local_clock+0x6f/0x80
> [   26.573523]  [<ffffffff811c6939>] ? fget_light+0xf9/0x520
> [   26.573526]  [<ffffffff811c687c>] ? fget_light+0x3c/0x520
> [   26.573530]  [<ffffffff815737d9>] sys_sendmsg+0x49/0x90
> [   26.573537]  [<ffffffff816d8429>] system_call_fastpath+0x16/0x1b
> [   26.573541] ---[ end trace 9edc8e6bb8e18f3f ]---

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
