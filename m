From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: Wireless scanning while turning off the radio problem..
Date: Sun, 18 Jan 2015 13:24:23 +0200
Message-ID: <CANUX_P0LCr3fzqLyjKQbZ-P2hAV-Nk6=AMm=oFOWCLW34cRg2w@mail.gmail.com>
References: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:39667 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbbARLYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 06:24:25 -0500
In-Reply-To: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On Sun, Jan 18, 2015 at 5:25 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> So there seems to be some issue with unlucky timing when turning off
> wireless while the driver is busy scanning. I can't reproduce this, so
> it's a one-off, but it's not just ugly warnings, the kernel woudln't
> scan any wireless on that device afterwards and I had to reboot to get
> networking back, so there is some long-term damage.
>
> This is with Intel wireless (iwlwifi, it's a iwl N7260 thing, rev
> 0x144 if anybody cares) , but the warning callbacks don't seem to be
> iwl-specific.
>
> This was a recent top-of-git kernel (3.19.0-rc4-00241-gfc7f0dd38172 to
> be exact).
>
> Anybody have any ideas? Anything in particular I should try out to
> help possibly get more information?
>

we have different scan flows based on the firmware version you have,
so it would help if you could tell me what firmware you have. iwlwifi
prints the firmware version when it loads it:

loaded firmware version X.X.X.X op_mode iwl_mvm.

I'll compile your tree to try to reproduce tonight.

>               Linus
>
> ---
> [  204.361145] iwlwifi 0000:01:00.0: RF_KILL bit toggled to disable radio.
> [  204.362358] ------------[ cut here ]------------
> [  204.362383] WARNING: CPU: 0 PID: 37 at net/wireless/core.c:1011
> cfg80211_netdev_notifier_call+0x491/0x500 [cfg80211]()
> [  204.362385] Modules linked in: ccm rfcomm fuse ip6t_rpfilter
> ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat
> ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle
> ip6table_security ip6table_raw ip6table_filter ip6_tables
> iptable_mangle iptable_security iptable_raw bnep arc4 vfat fat
> x86_pkg_temp_thermal pn544_mei mei_phy pn544 coretemp hci kvm_intel
> nfc iTCO_wdt iTCO_vendor_support kvm iwlmvm uvcvideo
> snd_hda_codec_realtek microcode snd_hda_codec_generic
> snd_hda_codec_hdmi mac80211 videobuf2_vmalloc videobuf2_memops
> videobuf2_core v4l2_common snd_hda_intel videodev snd_hda_controller
> joydev btusb media hid_multitouch i2c_i801 snd_hda_codec serio_raw
> iwlwifi bluetooth snd_hwdep snd_seq cfg80211 snd_seq_device
> [  204.362432]  snd_pcm sony_laptop rfkill mei_me snd_timer mei snd
> lpc_ich mfd_core shpchp soundcore dm_crypt i915 crct10dif_pclmul
> crc32_pclmul crc32c_intel i2c_algo_bit ghash_clmulni_intel
> drm_kms_helper drm i2c_core video
> [  204.362453] CPU: 0 PID: 37 Comm: kworker/0:1 Not tainted
> 3.19.0-rc4-00241-gfc7f0dd38172 #14
> [  204.362455] Hardware name: Sony Corporation SVP11213CXB/VAIO, BIOS
> R0270V7 05/17/2013
> [  204.362464] Workqueue: events cfg80211_rfkill_sync_work [cfg80211]
> [  204.362467]  0000000000000000 ffffffffc0375870 ffffffff815eb39a
> 0000000000000000
> [  204.362471]  ffffffff8106c357 ffff8800d3b12890 ffff8800d9e08260
> 0000000000000002
> [  204.362475]  ffff8800d3b12000 ffff8800d9e08000 ffffffffc0350161
> ffff8800d365dc00
> [  204.362479] Call Trace:
> [  204.362490]  [<ffffffff815eb39a>] ? dump_stack+0x40/0x50
> [  204.362496]  [<ffffffff8106c357>] ? warn_slowpath_common+0x77/0xb0
> [  204.362506]  [<ffffffffc0350161>] ?
> cfg80211_netdev_notifier_call+0x491/0x500 [cfg80211]
> [  204.362513]  [<ffffffff814f3769>] ? __dev_remove_pack+0x39/0xa0
> [  204.362538]  [<ffffffff815d9d0c>] ? __unregister_prot_hook+0xcc/0xd0
> [  204.362542]  [<ffffffff815da89c>] ? packet_notifier+0x15c/0x1b0
> [  204.362549]  [<ffffffff81086e65>] ? notifier_call_chain+0x45/0x70
> [  204.362552]  [<ffffffff814f41a9>] ? dev_close_many+0xb9/0x110
> [  204.362556]  [<ffffffff814f65da>] ? dev_close.part.87+0x2a/0x40
> [  204.362559]  [<ffffffff814f6609>] ? dev_close+0x19/0x20
> [  204.362569]  [<ffffffffc034f76d>] ?
> cfg80211_shutdown_all_interfaces+0x3d/0xb0 [cfg80211]
> [  204.362577]  [<ffffffffc034f809>] ?
> cfg80211_rfkill_sync_work+0x29/0x30 [cfg80211]
> [  204.362580]  [<ffffffff81081335>] ? process_one_work+0x135/0x370
> [  204.362585]  [<ffffffff8107e927>] ? pwq_activate_delayed_work+0x27/0x40
> [  204.362589]  [<ffffffff810818c3>] ? worker_thread+0x63/0x480
> [  204.362592]  [<ffffffff81081860>] ? rescuer_thread+0x2f0/0x2f0
> [  204.362596]  [<ffffffff8108606e>] ? kthread+0xce/0xf0
> [  204.362600]  [<ffffffff81085fa0>] ? kthread_create_on_node+0x180/0x180
> [  204.362605]  [<ffffffff815f0eac>] ? ret_from_fork+0x7c/0xb0
> [  204.362609]  [<ffffffff81085fa0>] ? kthread_create_on_node+0x180/0x180
> [  204.362612] ---[ end trace d0ac2826f7d2747f ]---
>
> [  204.362614] ------------[ cut here ]------------
> [  204.362628] WARNING: CPU: 0 PID: 37 at net/mac80211/driver-ops.h:12
> ieee80211_request_sched_scan_stop+0xdd/0xf0 [mac80211]()
> [  204.362630] wlp1s0:  Failed check-sdata-in-driver check, flags: 0x4
> [  204.362631] Modules linked in: ccm rfcomm fuse ip6t_rpfilter
> ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat
> ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle
> ip6table_security ip6table_raw ip6table_filter ip6_tables
> iptable_mangle iptable_security iptable_raw bnep arc4 vfat fat
> x86_pkg_temp_thermal pn544_mei mei_phy pn544 coretemp hci kvm_intel
> nfc iTCO_wdt iTCO_vendor_support kvm iwlmvm uvcvideo
> snd_hda_codec_realtek microcode snd_hda_codec_generic
> snd_hda_codec_hdmi mac80211 videobuf2_vmalloc videobuf2_memops
> videobuf2_core v4l2_common snd_hda_intel videodev snd_hda_controller
> joydev btusb media hid_multitouch i2c_i801 snd_hda_codec serio_raw
> iwlwifi bluetooth snd_hwdep snd_seq cfg80211 snd_seq_device
> [  204.362677]  snd_pcm sony_laptop rfkill mei_me snd_timer mei snd
> lpc_ich mfd_core shpchp soundcore dm_crypt i915 crct10dif_pclmul
> crc32_pclmul crc32c_intel i2c_algo_bit ghash_clmulni_intel
> drm_kms_helper drm i2c_core video
> [  204.362695] CPU: 0 PID: 37 Comm: kworker/0:1 Tainted: G        W
>   3.19.0-rc4-00241-gfc7f0dd38172 #14
> [  204.362697] Hardware name: Sony Corporation SVP11213CXB/VAIO, BIOS
> R0270V7 05/17/2013
> [  204.362703] Workqueue: events cfg80211_rfkill_sync_work [cfg80211]
> [  204.362705]  0000000000000000 ffffffffc04e3491 ffffffff815eb39a
> ffff88011a697c18
> [  204.362709]  ffffffff8106c357 ffff8800d9e08660 ffff8800d3b12880
> 00000000fffffffb
> [  204.362713]  ffff8800d9e09618 ffff8800d9e08000 ffffffff8106c3d5
> ffffffffc04e0e78
> [  204.362717] Call Trace:
> [  204.362723]  [<ffffffff815eb39a>] ? dump_stack+0x40/0x50
> [  204.362726]  [<ffffffff8106c357>] ? warn_slowpath_common+0x77/0xb0
> [  204.362730]  [<ffffffff8106c3d5>] ? warn_slowpath_fmt+0x45/0x50
> [  204.362743]  [<ffffffffc049374d>] ?
> ieee80211_request_sched_scan_stop+0xdd/0xf0 [mac80211]
> [  204.362755]  [<ffffffffc0357a33>] ?
> __cfg80211_stop_sched_scan+0x73/0xb0 [cfg80211]
> [  204.362763]  [<ffffffffc035016b>] ?
> cfg80211_netdev_notifier_call+0x49b/0x500 [cfg80211]
> [  204.362768]  [<ffffffff814f3769>] ? __dev_remove_pack+0x39/0xa0
> [  204.362772]  [<ffffffff815d9d0c>] ? __unregister_prot_hook+0xcc/0xd0
> [  204.362776]  [<ffffffff815da89c>] ? packet_notifier+0x15c/0x1b0
> [  204.362781]  [<ffffffff81086e65>] ? notifier_call_chain+0x45/0x70
> [  204.362785]  [<ffffffff814f41a9>] ? dev_close_many+0xb9/0x110
> [  204.362788]  [<ffffffff814f65da>] ? dev_close.part.87+0x2a/0x40
> [  204.362792]  [<ffffffff814f6609>] ? dev_close+0x19/0x20
> [  204.362800]  [<ffffffffc034f76d>] ?
> cfg80211_shutdown_all_interfaces+0x3d/0xb0 [cfg80211]
> [  204.362807]  [<ffffffffc034f809>] ?
> cfg80211_rfkill_sync_work+0x29/0x30 [cfg80211]
> [  204.362811]  [<ffffffff81081335>] ? process_one_work+0x135/0x370
> [  204.362815]  [<ffffffff8107e927>] ? pwq_activate_delayed_work+0x27/0x40
> [  204.362819]  [<ffffffff810818c3>] ? worker_thread+0x63/0x480
> [  204.362822]  [<ffffffff81081860>] ? rescuer_thread+0x2f0/0x2f0
> [  204.362826]  [<ffffffff8108606e>] ? kthread+0xce/0xf0
> [  204.362830]  [<ffffffff81085fa0>] ? kthread_create_on_node+0x180/0x180
> [  204.362834]  [<ffffffff815f0eac>] ? ret_from_fork+0x7c/0xb0
> [  204.362838]  [<ffffffff81085fa0>] ? kthread_create_on_node+0x180/0x180
> [  204.362840] ---[ end trace d0ac2826f7d27480 ]---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
