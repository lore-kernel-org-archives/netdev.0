From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [linuxwifi] [-next] WARNING at
 iwl_mvm_time_event_send_add+0x72/0x1b6
Date: Mon, 26 Oct 2015 07:51:23 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8B0828@hasmsx107.ger.corp.intel.com>
References: <20151026063932.GA31271@swordfish>
 <0BA3FCBA62E2DC44AF3030971E174FB32E8B0644@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linuxwifi <linuxwifi@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:61318 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752901AbbJZHva convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 03:51:30 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/26/2015 09:23 AM, Grumbach, Emmanuel wrote:
> Hi,
> 
> On 10/26/2015 08:41 AM, Sergey Senozhatsky wrote:
>> Hi,
>>
>> linux-next 20151022
>>
>>
> 
> Can be reproduced reliably?
> Seems like a bad race between the end of session protection for the
> authentication and the start of the session protection for the deauth.
> I think I found the hole in the locks in there, but it is going to be
> tricky to solve.

Not sure if I found the race. Can you please send the complete log?
If you have timestamps, it'd greatly helps...
dmesg output should do.

> 
>> wlp2s0: aborting authentication with 00:04:96:61:cd:e0 by local choice (Reason: 3=DEAUTH_LEAVING)
>> ------------[ cut here ]------------
>> WARNING: CPU: 0 PID: 1006 at drivers/net/wireless/iwlwifi/mvm/time-event.c:513 iwl_mvm_time_event_send_add+0x72/0x1b6 [iwlmvm]()
>> Modules linked in: mousedev arc4 nls_iso8859_1 nls_cp437 vfat fat serio_raw psmouse atkbd coretemp hwmon i915 libps2 iwlmvm i2c_algo_bit mac80211 drm_kms_helper cfbfillrect intel_powerclamp syscopyarea cfbimgblt sysfillrect sysimgblt crc32c_intel fb_sys_fops cfbcopyarea iwlwifi drm r8
>> CPU: 0 PID: 1006 Comm: iwconfig Not tainted 4.3.0-rc6-next-20151022-dbg-00002-g4041783-dirty #260
>>  0000000000000000 ffff8800c69479c8 ffffffff811dd4ad 0000000000000000
>>  ffff8800c6947a00 ffffffff8103db4e ffffffffa04fd261 ffff88041c7cdfc8
>>  ffff88041cc87a20 ffff88041c7ceb28 ffff8800c6947aac ffff8800c6947a10
>> Call Trace:
>>  [<ffffffff811dd4ad>] dump_stack+0x4b/0x63
>>  [<ffffffff8103db4e>] warn_slowpath_common+0x99/0xb2
>>  [<ffffffffa04fd261>] ? iwl_mvm_time_event_send_add+0x72/0x1b6 [iwlmvm]
>>  [<ffffffff8103dc1a>] warn_slowpath_null+0x1a/0x1c
>>  [<ffffffffa04fd261>] iwl_mvm_time_event_send_add+0x72/0x1b6 [iwlmvm]
>>  [<ffffffff8107979f>] ? __lock_is_held+0x3c/0x57
>>  [<ffffffffa04fdb8b>] iwl_mvm_protect_session+0x150/0x219 [iwlmvm]
>>  [<ffffffffa04fdb8b>] ? iwl_mvm_protect_session+0x150/0x219 [iwlmvm]
>>  [<ffffffffa04ecf57>] ? iwl_mvm_ref_sync+0x37/0x10c [iwlmvm]
>>  [<ffffffffa04ed475>] iwl_mvm_mac_mgd_prepare_tx+0xa4/0xc2 [iwlmvm]
>>  [<ffffffffa04ed475>] ? iwl_mvm_mac_mgd_prepare_tx+0xa4/0xc2 [iwlmvm]
>>  [<ffffffffa047be43>] ieee80211_mgd_deauth+0x14f/0x3b0 [mac80211]
>>  [<ffffffff8107979f>] ? __lock_is_held+0x3c/0x57
>>  [<ffffffffa0446758>] ieee80211_deauth+0x18/0x1a [mac80211]
>>  [<ffffffffa02bc4b2>] cfg80211_mlme_deauth+0x13c/0x28e [cfg80211]
>>  [<ffffffffa02c0f9a>] cfg80211_disconnect+0xb5/0x2f7 [cfg80211]
>>  [<ffffffffa02d901e>] cfg80211_mgd_wext_siwfreq+0xed/0x160 [cfg80211]
>>  [<ffffffffa02d8c81>] ? cfg80211_wext_freq+0x5f/0x5f [cfg80211]
>>  [<ffffffffa02d8cf7>] cfg80211_wext_siwfreq+0x76/0xf6 [cfg80211]
>>  [<ffffffff813a9809>] ioctl_standard_call+0x66/0x376
>>  [<ffffffff813a9caa>] wext_handle_ioctl+0x102/0x16d
>>  [<ffffffff8130782b>] dev_ioctl+0x6bb/0x6de
>>  [<ffffffff81113adc>] ? handle_mm_fault+0xefc/0x13f9
>>  [<ffffffff812d73d0>] sock_ioctl+0x230/0x23c
>>  [<ffffffff812d73d0>] ? sock_ioctl+0x230/0x23c
>>  [<ffffffff8115047d>] do_vfs_ioctl+0x458/0x4dc
>>  [<ffffffff813b3635>] ? retint_user+0x18/0x20
>>  [<ffffffff8115a5fe>] ? __fget_light+0x4d/0x71
>>  [<ffffffff81150544>] SyS_ioctl+0x43/0x61
>>  [<ffffffff813b2b57>] entry_SYSCALL_64_fastpath+0x12/0x6f
>> ---[ end trace 6a44e7f1588bdae7 ]---
>>
>>
>> 	-ss
>> -------------------------------------
>> linuxwifi@eclists.intel.com
>> https://eclists.intel.com/sympa/info/linuxwifi
>> Unsubscribe by sending email to sympa@eclists.intel.com with subject "Unsubscribe linuxwifi"
>>
> 
