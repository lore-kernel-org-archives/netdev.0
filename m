From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [linuxwifi] [-next] WARNING at
 iwl_mvm_time_event_send_add+0x72/0x1b6
Date: Mon, 26 Oct 2015 17:28:33 +0900
Message-ID: <20151026082833.GA592@swordfish>
References: <20151026063932.GA31271@swordfish>
 <0BA3FCBA62E2DC44AF3030971E174FB32E8B0644@hasmsx107.ger.corp.intel.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32E8B0828@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linuxwifi <linuxwifi@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32E8B0828@hasmsx107.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/26/15 07:51), Grumbach, Emmanuel wrote:
> > On 10/26/2015 08:41 AM, Sergey Senozhatsky wrote:
> >> Hi,
> >>
> >> linux-next 20151022
> >>
> >>
> > 
> > Can be reproduced reliably?
> > Seems like a bad race between the end of session protection for the
> > authentication and the start of the session protection for the deauth.
> > I think I found the hole in the locks in there, but it is going to be
> > tricky to solve.
> 
> Not sure if I found the race. Can you please send the complete log?
> If you have timestamps, it'd greatly helps...
> dmesg output should do.
> 

Hi,

not really sure if I can reproduce this one easily. seen once.

---

Oct 26 15:20:51  dhclient[399]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 7
Oct 26 15:20:58  dhclient[399]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 17
Oct 26 15:21:09  dhclient[539]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 7
Oct 26 15:21:09  kernel: wlp2s0: authenticate with 00:04:96:69:0d:80
Oct 26 15:21:09  kernel: wlp2s0: send auth to 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:21:09  kernel: wlp2s0: authenticated
Oct 26 15:21:09  kernel: wlp2s0: associate with 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:21:09  kernel: wlp2s0: RX AssocResp from 00:04:96:69:0d:80 (capab=0x11 status=0 aid=24)
Oct 26 15:21:09  kernel: wlp2s0: associated
Oct 26 15:21:09  kernel: IPv6: ADDRCONF(NETDEV_CHANGE): wlp2s0: link becomes ready
Oct 26 15:21:09  kernel: wlp2s0: deauthenticating from 00:04:96:69:0d:80 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:21:12  kernel: wlp2s0: authenticate with 00:04:96:61:e9:f0
Oct 26 15:21:12  kernel: wlp2s0: send auth to 00:04:96:61:e9:f0 (try 1/3)
Oct 26 15:21:12  kernel: wlp2s0: authenticated
Oct 26 15:21:12  kernel: wlp2s0: associate with 00:04:96:61:e9:f0 (try 1/3)
Oct 26 15:21:12  kernel: wlp2s0: RX AssocResp from 00:04:96:61:e9:f0 (capab=0x11 status=0 aid=16)
Oct 26 15:21:12  kernel: wlp2s0: associated
Oct 26 15:21:12  kernel: wlp2s0: deauthenticating from 00:04:96:61:e9:f0 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:21:16  dhclient[539]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 10
Oct 26 15:21:22  kernel: wlp2s0: authenticate with 00:04:96:69:0d:80
Oct 26 15:21:22  kernel: wlp2s0: send auth to 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:21:22  kernel: wlp2s0: authenticated
Oct 26 15:21:22  kernel: wlp2s0: associate with 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:21:22  kernel: wlp2s0: RX AssocResp from 00:04:96:69:0d:80 (capab=0x11 status=0 aid=25)
Oct 26 15:21:22  kernel: wlp2s0: associated
Oct 26 15:21:22  kernel: wlp2s0: deauthenticating from 00:04:96:69:0d:80 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:21:26  dhclient[539]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 9
Oct 26 15:21:35  dhclient[539]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 12
Oct 26 15:21:47  kernel: wlp2s0: authenticate with 00:04:96:69:0d:80
Oct 26 15:21:47  kernel: wlp2s0: send auth to 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:21:47  kernel: wlp2s0: authenticated
Oct 26 15:21:47  kernel: wlp2s0: associate with 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:21:47  kernel: wlp2s0: RX AssocResp from 00:04:96:69:0d:80 (capab=0x11 status=0 aid=25)
Oct 26 15:21:47  kernel: wlp2s0: associated
Oct 26 15:21:47  kernel: wlp2s0: deauthenticating from 00:04:96:69:0d:80 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:21:47  dhclient[539]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 18
Oct 26 15:22:05  dhclient[539]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 5
Oct 26 15:22:10  dhclient[539]: No DHCPOFFERS received.
Oct 26 15:22:10  dhclient[539]: No working leases in persistent database - sleeping.
Oct 26 15:22:34  kernel: wlp2s0: authenticate with 00:04:96:69:0d:80
Oct 26 15:22:34  kernel: wlp2s0: send auth to 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:22:34  kernel: wlp2s0: authenticated
Oct 26 15:22:34  kernel: wlp2s0: associate with 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:22:34  kernel: wlp2s0: RX AssocResp from 00:04:96:69:0d:80 (capab=0x11 status=0 aid=29)
Oct 26 15:22:34  kernel: wlp2s0: associated
Oct 26 15:22:34  kernel: wlp2s0: deauthenticating from 00:04:96:69:0d:80 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:22:34  kernel: wlp2s0: authenticate with 00:04:96:61:cd:e0
Oct 26 15:22:34  kernel: wlp2s0: send auth to 00:04:96:61:cd:e0 (try 1/3)
Oct 26 15:22:34  kernel: wlp2s0: aborting authentication with 00:04:96:61:cd:e0 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:22:34  kernel: ------------[ cut here ]------------
Oct 26 15:22:34  kernel: WARNING: CPU: 0 PID: 1006 at drivers/net/wireless/iwlwifi/mvm/time-event.c:513 iwl_mvm_time_event_send_add+0x72/0x1b6 [iwlmvm]()
Oct 26 15:22:34  kernel: Modules linked in: mousedev arc4 nls_iso8859_1 nls_cp437 vfat fat serio_raw psmouse atkbd coretemp hwmon i915 libps2 iwlmvm i2c_algo_bit mac80211 drm_kms_helper cfbfillrect intel_powerclamp syscopyarea cfbimgblt sysfillrect sysimgblt crc32c_intel fb_sys_fops cfbcopyarea iwlwifi drm r8
Oct 26 15:22:34  kernel: CPU: 0 PID: 1006 Comm: iwconfig Not tainted 4.3.0-rc6-next-20151022-dbg-00002-g4041783-dirty #260
Oct 26 15:22:34  kernel:  0000000000000000 ffff8800c69479c8 ffffffff811dd4ad 0000000000000000
Oct 26 15:22:34  kernel:  ffff8800c6947a00 ffffffff8103db4e ffffffffa04fd261 ffff88041c7cdfc8
Oct 26 15:22:34  kernel:  ffff88041cc87a20 ffff88041c7ceb28 ffff8800c6947aac ffff8800c6947a10
Oct 26 15:22:34  kernel: Call Trace:
Oct 26 15:22:34  kernel:  [<ffffffff811dd4ad>] dump_stack+0x4b/0x63
Oct 26 15:22:34  kernel:  [<ffffffff8103db4e>] warn_slowpath_common+0x99/0xb2
Oct 26 15:22:34  kernel:  [<ffffffffa04fd261>] ? iwl_mvm_time_event_send_add+0x72/0x1b6 [iwlmvm]
Oct 26 15:22:34  kernel:  [<ffffffff8103dc1a>] warn_slowpath_null+0x1a/0x1c
Oct 26 15:22:34  kernel:  [<ffffffffa04fd261>] iwl_mvm_time_event_send_add+0x72/0x1b6 [iwlmvm]
Oct 26 15:22:34  kernel:  [<ffffffff8107979f>] ? __lock_is_held+0x3c/0x57
Oct 26 15:22:34  kernel:  [<ffffffffa04fdb8b>] iwl_mvm_protect_session+0x150/0x219 [iwlmvm]
Oct 26 15:22:34  kernel:  [<ffffffffa04fdb8b>] ? iwl_mvm_protect_session+0x150/0x219 [iwlmvm]
Oct 26 15:22:34  kernel:  [<ffffffffa04ecf57>] ? iwl_mvm_ref_sync+0x37/0x10c [iwlmvm]
Oct 26 15:22:34  kernel:  [<ffffffffa04ed475>] iwl_mvm_mac_mgd_prepare_tx+0xa4/0xc2 [iwlmvm]
Oct 26 15:22:34  kernel:  [<ffffffffa04ed475>] ? iwl_mvm_mac_mgd_prepare_tx+0xa4/0xc2 [iwlmvm]
Oct 26 15:22:34  kernel:  [<ffffffffa047be43>] ieee80211_mgd_deauth+0x14f/0x3b0 [mac80211]
Oct 26 15:22:34  kernel:  [<ffffffff8107979f>] ? __lock_is_held+0x3c/0x57
Oct 26 15:22:34  kernel:  [<ffffffffa0446758>] ieee80211_deauth+0x18/0x1a [mac80211]
Oct 26 15:22:34  kernel:  [<ffffffffa02bc4b2>] cfg80211_mlme_deauth+0x13c/0x28e [cfg80211]
Oct 26 15:22:34  kernel:  [<ffffffffa02c0f9a>] cfg80211_disconnect+0xb5/0x2f7 [cfg80211]
Oct 26 15:22:34  kernel:  [<ffffffffa02d901e>] cfg80211_mgd_wext_siwfreq+0xed/0x160 [cfg80211]
Oct 26 15:22:34  kernel:  [<ffffffffa02d8c81>] ? cfg80211_wext_freq+0x5f/0x5f [cfg80211]
Oct 26 15:22:34  kernel:  [<ffffffffa02d8cf7>] cfg80211_wext_siwfreq+0x76/0xf6 [cfg80211]
Oct 26 15:22:34  kernel:  [<ffffffff813a9809>] ioctl_standard_call+0x66/0x376
Oct 26 15:22:34  kernel:  [<ffffffff813a9caa>] wext_handle_ioctl+0x102/0x16d
Oct 26 15:22:34  kernel:  [<ffffffff8130782b>] dev_ioctl+0x6bb/0x6de
Oct 26 15:22:34  kernel:  [<ffffffff81113adc>] ? handle_mm_fault+0xefc/0x13f9
Oct 26 15:22:34  kernel:  [<ffffffff812d73d0>] sock_ioctl+0x230/0x23c
Oct 26 15:22:34  kernel:  [<ffffffff812d73d0>] ? sock_ioctl+0x230/0x23c
Oct 26 15:22:34  kernel:  [<ffffffff8115047d>] do_vfs_ioctl+0x458/0x4dc
Oct 26 15:22:34  kernel:  [<ffffffff813b3635>] ? retint_user+0x18/0x20
Oct 26 15:22:34  kernel:  [<ffffffff8115a5fe>] ? __fget_light+0x4d/0x71
Oct 26 15:22:34  kernel:  [<ffffffff81150544>] SyS_ioctl+0x43/0x61
Oct 26 15:22:34  kernel:  [<ffffffff813b2b57>] entry_SYSCALL_64_fastpath+0x12/0x6f
Oct 26 15:22:34  kernel: ---[ end trace 6a44e7f1588bdae7 ]---
Oct 26 15:22:34  kernel: wlp2s0: authenticate with 00:04:96:68:d7:60
Oct 26 15:22:34  kernel: wlp2s0: send auth to 00:04:96:68:d7:60 (try 1/3)
Oct 26 15:22:34  kernel: wlp2s0: send auth to 00:04:96:68:d7:60 (try 2/3)
Oct 26 15:22:34  kernel: wlp2s0: authenticated
Oct 26 15:22:34  kernel: wlp2s0: associate with 00:04:96:68:d7:60 (try 1/3)
Oct 26 15:22:34  kernel: wlp2s0: RX AssocResp from 00:04:96:68:d7:60 (capab=0x411 status=0 aid=4)
Oct 26 15:22:34  kernel: wlp2s0: associated
Oct 26 15:22:34  kernel: wlp2s0: deauthenticating from 00:04:96:68:d7:60 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:22:34  dhclient[1011]: DHCPDISCOVER on wlp2s0 to 255.255.255.255 port 67 interval 8
Oct 26 15:22:37  kernel: wlp2s0: authenticate with 00:04:96:69:0d:80
Oct 26 15:22:37  kernel: wlp2s0: send auth to 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:22:37  kernel: wlp2s0: authenticated
Oct 26 15:22:37  kernel: wlp2s0: associate with 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:22:37  kernel: wlp2s0: RX AssocResp from 00:04:96:69:0d:80 (capab=0x11 status=0 aid=29)
Oct 26 15:22:37  kernel: wlp2s0: associated
Oct 26 15:22:37  kernel: wlp2s0: deauthenticating from 00:04:96:69:0d:80 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:22:40  kernel: wlp2s0: authenticate with 00:04:96:61:e9:f0
Oct 26 15:22:40  kernel: wlp2s0: send auth to 00:04:96:61:e9:f0 (try 1/3)
Oct 26 15:22:40  kernel: wlp2s0: authenticated
Oct 26 15:22:40  kernel: wlp2s0: associate with 00:04:96:61:e9:f0 (try 1/3)
Oct 26 15:22:40  kernel: wlp2s0: RX AssocResp from 00:04:96:61:e9:f0 (capab=0x11 status=0 aid=19)
Oct 26 15:22:40  kernel: wlp2s0: associated
Oct 26 15:22:40  kernel: wlp2s0: deauthenticating from 00:04:96:61:e9:f0 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:22:42  kernel: wlp2s0: authenticate with 00:04:96:62:10:e0
Oct 26 15:22:42  kernel: wlp2s0: send auth to 00:04:96:62:10:e0 (try 1/3)
Oct 26 15:22:42  kernel: wlp2s0: authenticated
Oct 26 15:22:42  kernel: wlp2s0: associate with 00:04:96:62:10:e0 (try 1/3)
Oct 26 15:22:42  kernel: wlp2s0: RX AssocResp from 00:04:96:62:10:e0 (capab=0x411 status=0 aid=2)
Oct 26 15:22:42  kernel: wlp2s0: associated
Oct 26 15:22:42  kernel: wlp2s0: deauthenticating from 00:04:96:62:10:e0 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:22:45  kernel: wlp2s0: authenticate with 00:04:96:61:bd:90
Oct 26 15:22:45  kernel: wlp2s0: send auth to 00:04:96:61:bd:90 (try 1/3)
Oct 26 15:22:45  kernel: wlp2s0: authenticated
Oct 26 15:22:45  kernel: wlp2s0: associate with 00:04:96:61:bd:90 (try 1/3)
Oct 26 15:22:45  kernel: wlp2s0: RX AssocResp from 00:04:96:61:bd:90 (capab=0x111 status=0 aid=4)
Oct 26 15:22:45  kernel: wlp2s0: associated
Oct 26 15:22:45  kernel: wlp2s0: deauthenticating from 00:04:96:61:bd:90 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:22:55  kernel: wlp2s0: authenticate with 00:04:96:69:0d:80
Oct 26 15:22:55  kernel: wlp2s0: send auth to 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:22:55  kernel: wlp2s0: authenticated
Oct 26 15:22:55  kernel: wlp2s0: associate with 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:22:55  kernel: wlp2s0: RX AssocResp from 00:04:96:69:0d:80 (capab=0x11 status=0 aid=9)
Oct 26 15:22:55  kernel: wlp2s0: associated
Oct 26 15:22:55  kernel: wlp2s0: deauthenticating from 00:04:96:69:0d:80 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:22:57  kernel: wlp2s0: authenticate with 00:04:96:61:ed:40
Oct 26 15:22:57  kernel: wlp2s0: send auth to 00:04:96:61:ed:40 (try 1/3)
Oct 26 15:22:57  kernel: wlp2s0: authenticated
Oct 26 15:22:57  kernel: wlp2s0: associate with 00:04:96:61:ed:40 (try 1/3)
Oct 26 15:22:57  kernel: wlp2s0: RX AssocResp from 00:04:96:61:ed:40 (capab=0x11 status=0 aid=2)
Oct 26 15:22:57  kernel: wlp2s0: associated
Oct 26 15:22:57  kernel: wlp2s0: deauthenticating from 00:04:96:61:ed:40 by local choice (Reason: 3=DEAUTH_LEAVING)
Oct 26 15:23:23  kernel: wlp2s0: authenticate with 00:04:96:69:0d:80
Oct 26 15:23:23  kernel: wlp2s0: send auth to 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:23:23  kernel: wlp2s0: authenticated
Oct 26 15:23:23  kernel: wlp2s0: associate with 00:04:96:69:0d:80 (try 1/3)
Oct 26 15:23:23  kernel: wlp2s0: RX AssocResp from 00:04:96:69:0d:80 (capab=0x11 status=0 aid=31)
Oct 26 15:23:23  kernel: wlp2s0: associated
Oct 26 15:23:23  kernel: wlp2s0: deauthenticating from 00:04:96:69:0d:80 by local choice (Reason: 3=DEAUTH_LEAVING)

---

	-ss
