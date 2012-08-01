From: "Arend van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: assert_cfg80211_lock warning with Linux v3.5-8833-g2d53492
Date: Wed, 1 Aug 2012 17:38:34 +0200
Message-ID: <50194D7A.6060400@broadcom.com>
References: <20120801131232.GA1785@zod.bos.redhat.com>
 <20120801141810.GB27433@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Josh Boyer" <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Brett Rudley" <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Roland Vossen" <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Seth Forshee" <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120801141810.GB27433-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/01/2012 04:18 PM, John W. Linville wrote:
> On Wed, Aug 01, 2012 at 09:12:33AM -0400, Josh Boyer wrote:
> 
>> > [   26.573028] ------------[ cut here ]------------
>> > [   26.573042] WARNING: at net/wireless/core.h:125 assert_cfg80211_lock.part.8+0x15/0x17 [cfg80211]()
>> > [   26.573045] Hardware name: XPS 8300  
>> > [   26.573046] Modules linked in: xt_CHECKSUM iptable_mangle bridge stp llc ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_defrag_ipv4 xt_state nf_conntrack ib_iser rdma_cm ib_addr ip6table_filter tpm_bios ip6_tables iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel arc4 brcmsmac snd_hda_codec cordic brcmutil snd_hwdep mac80211 snd_pcm snd_page_alloc snd_timer cfg80211 snd coretemp rfkill serio_raw i2c_i801 soundcore lpc_ich bcma dcdbas microcode mfd_core mei vhost_net tun macvtap macvlan kvm_intel nfsd kvm auth_rpcgss nfs_acl lockd uinput crc32c_intel ghash_clmulni_intel broadcom tg3 usb_storage uas radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core sunrpc be2iscsi bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxg
 bi libiscsi_tcp qla4xxx iscsi_boot_sysfs libiscsi scsi_transport_iscsi
>> > [   26.573143] Pid: 757, comm: NetworkManager Not tainted 3.6.0-0.rc0.git8.1.fc18.x86_64 #1
>> > [   26.573145] Call Trace:
>> > [   26.573153]  [<ffffffff8106782f>] warn_slowpath_common+0x7f/0xc0
>> > [   26.573159]  [<ffffffff8106788a>] warn_slowpath_null+0x1a/0x20
>> > [   26.573170]  [<ffffffffa04c730d>] assert_cfg80211_lock.part.8+0x15/0x17 [cfg80211]
>> > [   26.573181]  [<ffffffffa04a8dcb>] freq_reg_info+0x6b/0x80 [cfg80211]
> brcmsmac needs to hold cfg80211_mutex before calling freq_reg_info...
> 
> It looks like those calls were added in mid-June.
> 

I think mid-june sounds about right. We never observed the warning when
changes to use regulatory infrastructure were tested/reviewed. Should
this precondition be mentioned in cfg80211.h?

Gr. AvS

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
