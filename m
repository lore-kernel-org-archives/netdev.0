From: wwguy <wey-yi.w.guy@intel.com>
Subject: Re: iwlagn: WARN_ON() in iwl_get_idle_rx_chain_count()
Date: Fri, 14 Oct 2011 08:29:18 -0700
Message-ID: <1318606158.12009.2.camel@wwguy-ubuntu>
References: <20111014150219.GA20672@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ddehr5Uv/cMFiUd8MalR"
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39911 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933221Ab1JNPfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 11:35:01 -0400
In-Reply-To: <20111014150219.GA20672@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ddehr5Uv/cMFiUd8MalR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

Hi Michal,

Could you try the attach patch and see if it fix your problem.

Thanks
Wey

On Fri, 2011-10-14 at 08:02 -0700, Michał Mirosław wrote:
> WARN_ON() in iwl_get_idle_rx_chain_count() gets triggered on system shutdown
> when WiFi card is associated to an AP. This is on kernel built from
> Linus' tree, commit 37cf95162af4036b4198756a590aab8126fa2ce4 (3.1.0-rc9+).
> It looks HT-related, I can't reproduce this on 802.11g network.
> 
> Best Regards,
> Michał Mirosław
> 
> 
> 09:00.0 Network controller: Intel Corporation Centrino Wireless-N 1030 (rev 34)
>         Subsystem: Intel Corporation Centrino Wireless-N 1030 BGN
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 52
>         Region 0: Memory at f7a00000 (64-bit, non-prefetchable) [size=8K]
>         Capabilities: <access denied>
>         Kernel driver in use: iwlagn
> 
> Oct 14 00:04:26 oko kernel: [ 2796.354030] ------------[ cut here ]------------
> Oct 14 00:04:26 oko kernel: [ 2796.354996] WARNING: at /usr/src/linux-git/drivers/net/wireless/iwlwifi/iwl-agn-lib.c:1766 iwlagn_set_rxon_chain+0x107/0x1b2 [iwlagn]()
> Oct 14 00:04:26 oko kernel: [ 2796.355955] Hardware name: Vostro 3350
> Oct 14 00:04:26 oko kernel: [ 2796.356906] invalid SMPS mode 0
> Oct 14 00:04:26 oko kernel: [ 2796.356920] Modules linked in: acpi_cpufreq mperf cpufreq_conservative autofs4 rfcomm cpufreq_stats bnep cpufreq_powersave cpufreq_userspace pci_stub binfmt_misc microcode uinput nfs lockd auth_rpcgss nfs_acl sunrpc ext2 coretemp loop kvm_intel kvm aesni_intel cryptd aes_x86_64 aes_generic ecb btusb radeon bluetooth uvcvideo usb_storage videodev arc4 media uas iwlagn v4l2_compat_ioctl32 i915 crc16 snd_hda_codec_idt ttm drm_kms_helper mac80211 drm snd_hda_intel snd_hda_codec ehci_hcd snd_hwdep xhci_hcd snd_pcm snd_seq usbcore joydev sg cfg80211 snd_timer sr_mod snd_seq_device snd r8169 psmouse dell_wmi cdrom dell_laptop soundcore i2c_algo_bit pcspkr evdev sparse_keymap processor snd_page_alloc video cfbcopyarea mii dcdbas button cfbimgblt cfbfillrect wmi ac 
 battery ext3 jbd mbcache dm_mod sd_mod crc_t10dif ahci libahci libata scsi_mod thermal thermal_sys [last unloaded: vboxdrv]
> Oct 14 00:04:26 oko kernel: [ 2796.365031] Pid: 3017, comm: wpa_supplicant Not tainted 3.1.0-rc9+ #12
> Oct 14 00:04:26 oko kernel: [ 2796.366263] Call Trace:
> Oct 14 00:04:26 oko kernel: [ 2796.367490]  [<ffffffff8103437f>] ? warn_slowpath_common+0x78/0x8c
> Oct 14 00:04:26 oko kernel: [ 2796.368673]  [<ffffffff8103442b>] ? warn_slowpath_fmt+0x45/0x4a
> Oct 14 00:04:26 oko kernel: [ 2796.369836]  [<ffffffffa0310733>] ? __sta_info_destroy+0x267/0x2af [mac80211]
> Oct 14 00:04:26 oko kernel: [ 2796.371046]  [<ffffffffa03a93f1>] ? iwlagn_set_rxon_chain+0x107/0x1b2 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.372274]  [<ffffffffa03b2f9e>] ? iwlagn_bss_info_changed+0x245/0x4b3 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.373753]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.374990]  [<ffffffffa031c03a>] ? __ieee80211_recalc_idle+0xef/0x194 [mac80211]
> Oct 14 00:04:26 oko kernel: [ 2796.376272]  [<ffffffffa031cbee>] ? ieee80211_recalc_idle+0x1e/0x42 [mac80211]
> Oct 14 00:04:26 oko kernel: [ 2796.377506]  [<ffffffffa0319690>] ? ieee80211_mgd_deauth+0x19c/0x1c0 [mac80211]
> Oct 14 00:04:26 oko kernel: [ 2796.378771]  [<ffffffff812e96ed>] ? sub_preempt_count+0x83/0x94
> Oct 14 00:04:26 oko kernel: [ 2796.380083]  [<ffffffffa01ca76c>] ? __cfg80211_mlme_deauth+0x107/0x116 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.381293]  [<ffffffff812e64d9>] ? schedule_hrtimeout_range_clock+0xc8/0x103
> Oct 14 00:04:26 oko kernel: [ 2796.382550]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.383803]  [<ffffffffa01ca7e4>] ? cfg80211_mlme_deauth+0x69/0x82 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.385039]  [<ffffffff81023735>] ? __wake_up_common+0x40/0x77
> Oct 14 00:04:26 oko kernel: [ 2796.386309]  [<ffffffffa01c15ed>] ? nl80211_deauthenticate+0xbc/0xc7 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.387607]  [<ffffffffa01c35cb>] ? nl80211_pre_doit+0x85/0xfb [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.389171]  [<ffffffff81250f71>] ? genl_rcv_msg+0x1cb/0x1f9
> Oct 14 00:04:26 oko kernel: [ 2796.390753]  [<ffffffff81250da6>] ? genl_rcv+0x28/0x28
> Oct 14 00:04:26 oko kernel: [ 2796.392295]  [<ffffffff81250a06>] ? netlink_rcv_skb+0x36/0x7a
> Oct 14 00:04:26 oko kernel: [ 2796.393896]  [<ffffffff81250d9d>] ? genl_rcv+0x1f/0x28
> Oct 14 00:04:26 oko kernel: [ 2796.395521]  [<ffffffff81250537>] ? netlink_unicast+0xe6/0x14e
> Oct 14 00:04:26 oko kernel: [ 2796.397095]  [<ffffffff81250819>] ? netlink_sendmsg+0x27a/0x2b2
> Oct 14 00:04:26 oko kernel: [ 2796.398741]  [<ffffffff810f45dc>] ? __pollwait+0xce/0xce
> Oct 14 00:04:26 oko kernel: [ 2796.400378]  [<ffffffff8122172d>] ? sock_sendmsg+0xc1/0xde
> Oct 14 00:04:26 oko kernel: [ 2796.402042]  [<ffffffff8122160e>] ? sock_recvmsg+0xcd/0xec
> Oct 14 00:04:26 oko kernel: [ 2796.403645]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.405148]  [<ffffffff8122160e>] ? sock_recvmsg+0xcd/0xec
> Oct 14 00:04:26 oko kernel: [ 2796.406650]  [<ffffffff812228d4>] ? move_addr_to_kernel+0x24/0x46
> Oct 14 00:04:26 oko kernel: [ 2796.408098]  [<ffffffff812219c5>] ? __sys_sendmsg+0x1e8/0x288
> Oct 14 00:04:26 oko kernel: [ 2796.408102]  [<ffffffff812e9798>] ? add_preempt_count+0x9a/0x9c
> Oct 14 00:04:26 oko kernel: [ 2796.408107]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.408109]  [<ffffffff812e96ed>] ? sub_preempt_count+0x83/0x94
> Oct 14 00:04:26 oko kernel: [ 2796.408112]  [<ffffffff812e6f14>] ? _raw_spin_unlock_irq+0x23/0x2f
> Oct 14 00:04:26 oko kernel: [ 2796.408115]  [<ffffffff810022e1>] ? do_signal+0x51d/0x5f3
> Oct 14 00:04:26 oko kernel: [ 2796.408119]  [<ffffffff81008f1b>] ? init_fpu+0x72/0x7f
> Oct 14 00:04:26 oko kernel: [ 2796.408122]  [<ffffffff8100969f>] ? check_for_xstate+0x1c/0x6f
> Oct 14 00:04:26 oko kernel: [ 2796.408124]  [<ffffffff81009966>] ? restore_i387_xstate+0x9e/0x17c
> Oct 14 00:04:26 oko kernel: [ 2796.408128]  [<ffffffff81044e92>] ? do_sigaltstack+0xaa/0x13e
> Oct 14 00:04:26 oko kernel: [ 2796.408131]  [<ffffffff812233c5>] ? sys_sendmsg+0x39/0x58
> Oct 14 00:04:26 oko kernel: [ 2796.408134]  [<ffffffff812ec17b>] ? system_call_fastpath+0x16/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.408176] ---[ end trace 634279251cfb99d1 ]---
> Oct 14 00:04:26 oko kernel: [ 2796.409026] ------------[ cut here ]------------
> Oct 14 00:04:26 oko kernel: [ 2796.409046] WARNING: at /usr/src/linux-git/drivers/net/wireless/iwlwifi/iwl-agn-lib.c:1766 iwlagn_set_rxon_chain+0x107/0x1b2 [iwlagn]()
> Oct 14 00:04:26 oko kernel: [ 2796.409048] Hardware name: Vostro 3350
> Oct 14 00:04:26 oko kernel: [ 2796.409049] invalid SMPS mode 0
> Oct 14 00:04:26 oko kernel: [ 2796.409050] Modules linked in: acpi_cpufreq mperf cpufreq_conservative autofs4 rfcomm cpufreq_stats bnep cpufreq_powersave cpufreq_userspace pci_stub binfmt_misc microcode uinput nfs lockd auth_rpcgss nfs_acl sunrpc ext2 coretemp loop kvm_intel kvm aesni_intel cryptd aes_x86_64 aes_generic ecb btusb radeon bluetooth uvcvideo usb_storage videodev arc4 media uas iwlagn v4l2_compat_ioctl32 i915 crc16 snd_hda_codec_idt ttm drm_kms_helper mac80211 drm snd_hda_intel snd_hda_codec ehci_hcd snd_hwdep xhci_hcd snd_pcm snd_seq usbcore joydev sg cfg80211 snd_timer sr_mod snd_seq_device snd r8169 psmouse dell_wmi cdrom dell_laptop soundcore i2c_algo_bit pcspkr evdev sparse_keymap processor snd_page_alloc video cfbcopyarea mii dcdbas button cfbimgblt cfbfillrect wmi ac 
 battery ext3 jbd mbcache dm_mod sd_mod crc_t10dif ahci libahci libata scsi_mod thermal thermal_sys [last unloaded: vboxdrv]
> Oct 14 00:04:26 oko kernel: [ 2796.409109] Pid: 3017, comm: wpa_supplicant Tainted: G        W   3.1.0-rc9+ #12
> Oct 14 00:04:26 oko kernel: [ 2796.409110] Call Trace:
> Oct 14 00:04:26 oko kernel: [ 2796.409116]  [<ffffffff8103437f>] ? warn_slowpath_common+0x78/0x8c
> Oct 14 00:04:26 oko kernel: [ 2796.409119]  [<ffffffff8103442b>] ? warn_slowpath_fmt+0x45/0x4a
> Oct 14 00:04:26 oko kernel: [ 2796.409133]  [<ffffffffa03b78e7>] ? iwl_send_cmd+0x1a4/0x303 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409140]  [<ffffffffa03a93f1>] ? iwlagn_set_rxon_chain+0x107/0x1b2 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409145]  [<ffffffffa03a276d>] ? iwl_update_chain_flags+0x32/0x58 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409156]  [<ffffffffa03af7cd>] ? iwl_power_set_mode+0xf4/0x157 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409163]  [<ffffffffa03af9e0>] ? iwl_power_update_mode+0x1b0/0x1b9 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409170]  [<ffffffffa03b2cd8>] ? iwlagn_mac_config+0x206/0x287 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409185]  [<ffffffffa0319690>] ? ieee80211_mgd_deauth+0x19c/0x1c0 [mac80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409188]  [<ffffffff812e96ed>] ? sub_preempt_count+0x83/0x94
> Oct 14 00:04:26 oko kernel: [ 2796.409201]  [<ffffffffa01ca76c>] ? __cfg80211_mlme_deauth+0x107/0x116 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409206]  [<ffffffff812e64d9>] ? schedule_hrtimeout_range_clock+0xc8/0x103
> Oct 14 00:04:26 oko kernel: [ 2796.409208]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.409216]  [<ffffffffa01ca7e4>] ? cfg80211_mlme_deauth+0x69/0x82 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409220]  [<ffffffff81023735>] ? __wake_up_common+0x40/0x77
> Oct 14 00:04:26 oko kernel: [ 2796.409228]  [<ffffffffa01c15ed>] ? nl80211_deauthenticate+0xbc/0xc7 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409238]  [<ffffffffa01c35cb>] ? nl80211_pre_doit+0x85/0xfb [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409244]  [<ffffffff81250f71>] ? genl_rcv_msg+0x1cb/0x1f9
> Oct 14 00:04:26 oko kernel: [ 2796.409246]  [<ffffffff81250da6>] ? genl_rcv+0x28/0x28
> Oct 14 00:04:26 oko kernel: [ 2796.409249]  [<ffffffff81250a06>] ? netlink_rcv_skb+0x36/0x7a
> Oct 14 00:04:26 oko kernel: [ 2796.409251]  [<ffffffff81250d9d>] ? genl_rcv+0x1f/0x28
> Oct 14 00:04:26 oko kernel: [ 2796.409253]  [<ffffffff81250537>] ? netlink_unicast+0xe6/0x14e
> Oct 14 00:04:26 oko kernel: [ 2796.409256]  [<ffffffff81250819>] ? netlink_sendmsg+0x27a/0x2b2
> Oct 14 00:04:26 oko kernel: [ 2796.409262]  [<ffffffff810f45dc>] ? __pollwait+0xce/0xce
> Oct 14 00:04:26 oko kernel: [ 2796.409266]  [<ffffffff8122172d>] ? sock_sendmsg+0xc1/0xde
> Oct 14 00:04:26 oko kernel: [ 2796.409268]  [<ffffffff8122160e>] ? sock_recvmsg+0xcd/0xec
> Oct 14 00:04:26 oko kernel: [ 2796.409271]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.409273]  [<ffffffff8122160e>] ? sock_recvmsg+0xcd/0xec
> Oct 14 00:04:26 oko kernel: [ 2796.409276]  [<ffffffff812228d4>] ? move_addr_to_kernel+0x24/0x46
> Oct 14 00:04:26 oko kernel: [ 2796.409279]  [<ffffffff812219c5>] ? __sys_sendmsg+0x1e8/0x288
> Oct 14 00:04:26 oko kernel: [ 2796.409282]  [<ffffffff812e9798>] ? add_preempt_count+0x9a/0x9c
> Oct 14 00:04:26 oko kernel: [ 2796.409284]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.409286]  [<ffffffff812e96ed>] ? sub_preempt_count+0x83/0x94
> Oct 14 00:04:26 oko kernel: [ 2796.409289]  [<ffffffff812e6f14>] ? _raw_spin_unlock_irq+0x23/0x2f
> Oct 14 00:04:26 oko kernel: [ 2796.409294]  [<ffffffff810022e1>] ? do_signal+0x51d/0x5f3
> Oct 14 00:04:26 oko kernel: [ 2796.409297]  [<ffffffff81008f1b>] ? init_fpu+0x72/0x7f
> Oct 14 00:04:26 oko kernel: [ 2796.409300]  [<ffffffff8100969f>] ? check_for_xstate+0x1c/0x6f
> Oct 14 00:04:26 oko kernel: [ 2796.409303]  [<ffffffff81009966>] ? restore_i387_xstate+0x9e/0x17c
> Oct 14 00:04:26 oko kernel: [ 2796.409305]  [<ffffffff81044e92>] ? do_sigaltstack+0xaa/0x13e
> Oct 14 00:04:26 oko kernel: [ 2796.409308]  [<ffffffff812233c5>] ? sys_sendmsg+0x39/0x58
> Oct 14 00:04:26 oko kernel: [ 2796.409312]  [<ffffffff812ec17b>] ? system_call_fastpath+0x16/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.409314] ---[ end trace 634279251cfb99d2 ]---
> Oct 14 00:04:26 oko kernel: [ 2796.409315] ------------[ cut here ]------------
> Oct 14 00:04:26 oko kernel: [ 2796.409325] WARNING: at /usr/src/linux-git/drivers/net/wireless/iwlwifi/iwl-agn-lib.c:1766 iwlagn_set_rxon_chain+0x107/0x1b2 [iwlagn]()
> Oct 14 00:04:26 oko kernel: [ 2796.409327] Hardware name: Vostro 3350
> Oct 14 00:04:26 oko kernel: [ 2796.409328] invalid SMPS mode 0
> Oct 14 00:04:26 oko kernel: [ 2796.409329] Modules linked in: acpi_cpufreq mperf cpufreq_conservative autofs4 rfcomm cpufreq_stats bnep cpufreq_powersave cpufreq_userspace pci_stub binfmt_misc microcode uinput nfs lockd auth_rpcgss nfs_acl sunrpc ext2 coretemp loop kvm_intel kvm aesni_intel cryptd aes_x86_64 aes_generic ecb btusb radeon bluetooth uvcvideo usb_storage videodev arc4 media uas iwlagn v4l2_compat_ioctl32 i915 crc16 snd_hda_codec_idt ttm drm_kms_helper mac80211 drm snd_hda_intel snd_hda_codec ehci_hcd snd_hwdep xhci_hcd snd_pcm snd_seq usbcore joydev sg cfg80211 snd_timer sr_mod snd_seq_device snd r8169 psmouse dell_wmi cdrom dell_laptop soundcore i2c_algo_bit pcspkr evdev sparse_keymap processor snd_page_alloc video cfbcopyarea mii dcdbas button cfbimgblt cfbfillrect wmi ac 
 battery ext3 jbd mbcache dm_mod sd_mod crc_t10dif ahci libahci libata scsi_mod thermal thermal_sys [last unloaded: vboxdrv]
> Oct 14 00:04:26 oko kernel: [ 2796.409371] Pid: 3017, comm: wpa_supplicant Tainted: G        W   3.1.0-rc9+ #12
> Oct 14 00:04:26 oko kernel: [ 2796.409372] Call Trace:
> Oct 14 00:04:26 oko kernel: [ 2796.409381]  [<ffffffff8103437f>] ? warn_slowpath_common+0x78/0x8c
> Oct 14 00:04:26 oko kernel: [ 2796.409384]  [<ffffffff8103442b>] ? warn_slowpath_fmt+0x45/0x4a
> Oct 14 00:04:26 oko kernel: [ 2796.409392]  [<ffffffffa03b78e7>] ? iwl_send_cmd+0x1a4/0x303 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409399]  [<ffffffffa03a93f1>] ? iwlagn_set_rxon_chain+0x107/0x1b2 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409408]  [<ffffffffa03a276d>] ? iwl_update_chain_flags+0x32/0x58 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409415]  [<ffffffffa03af7cd>] ? iwl_power_set_mode+0xf4/0x157 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409421]  [<ffffffffa03af9e0>] ? iwl_power_update_mode+0x1b0/0x1b9 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409429]  [<ffffffffa03b2cd8>] ? iwlagn_mac_config+0x206/0x287 [iwlagn]
> Oct 14 00:04:26 oko kernel: [ 2796.409439]  [<ffffffffa0319690>] ? ieee80211_mgd_deauth+0x19c/0x1c0 [mac80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409442]  [<ffffffff812e96ed>] ? sub_preempt_count+0x83/0x94
> Oct 14 00:04:26 oko kernel: [ 2796.409457]  [<ffffffffa01ca76c>] ? __cfg80211_mlme_deauth+0x107/0x116 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409460]  [<ffffffff812e64d9>] ? schedule_hrtimeout_range_clock+0xc8/0x103
> Oct 14 00:04:26 oko kernel: [ 2796.409463]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.409477]  [<ffffffffa01ca7e4>] ? cfg80211_mlme_deauth+0x69/0x82 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409479]  [<ffffffff81023735>] ? __wake_up_common+0x40/0x77
> Oct 14 00:04:26 oko kernel: [ 2796.409490]  [<ffffffffa01c15ed>] ? nl80211_deauthenticate+0xbc/0xc7 [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409498]  [<ffffffffa01c35cb>] ? nl80211_pre_doit+0x85/0xfb [cfg80211]
> Oct 14 00:04:26 oko kernel: [ 2796.409502]  [<ffffffff81250f71>] ? genl_rcv_msg+0x1cb/0x1f9
> Oct 14 00:04:26 oko kernel: [ 2796.409505]  [<ffffffff81250da6>] ? genl_rcv+0x28/0x28
> Oct 14 00:04:26 oko kernel: [ 2796.409507]  [<ffffffff81250a06>] ? netlink_rcv_skb+0x36/0x7a
> Oct 14 00:04:26 oko kernel: [ 2796.409509]  [<ffffffff81250d9d>] ? genl_rcv+0x1f/0x28
> Oct 14 00:04:26 oko kernel: [ 2796.409511]  [<ffffffff81250537>] ? netlink_unicast+0xe6/0x14e
> Oct 14 00:04:26 oko kernel: [ 2796.409514]  [<ffffffff81250819>] ? netlink_sendmsg+0x27a/0x2b2
> Oct 14 00:04:26 oko kernel: [ 2796.409517]  [<ffffffff810f45dc>] ? __pollwait+0xce/0xce
> Oct 14 00:04:26 oko kernel: [ 2796.409519]  [<ffffffff8122172d>] ? sock_sendmsg+0xc1/0xde
> Oct 14 00:04:26 oko kernel: [ 2796.409521]  [<ffffffff8122160e>] ? sock_recvmsg+0xcd/0xec
> Oct 14 00:04:26 oko kernel: [ 2796.409526]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.409529]  [<ffffffff8122160e>] ? sock_recvmsg+0xcd/0xec
> Oct 14 00:04:26 oko kernel: [ 2796.409532]  [<ffffffff812228d4>] ? move_addr_to_kernel+0x24/0x46
> Oct 14 00:04:26 oko kernel: [ 2796.409534]  [<ffffffff812219c5>] ? __sys_sendmsg+0x1e8/0x288
> Oct 14 00:04:26 oko kernel: [ 2796.409537]  [<ffffffff812e9798>] ? add_preempt_count+0x9a/0x9c
> Oct 14 00:04:26 oko kernel: [ 2796.409539]  [<ffffffff8102c1e5>] ? get_parent_ip+0x9/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.409542]  [<ffffffff812e96ed>] ? sub_preempt_count+0x83/0x94
> Oct 14 00:04:26 oko kernel: [ 2796.409544]  [<ffffffff812e6f14>] ? _raw_spin_unlock_irq+0x23/0x2f
> Oct 14 00:04:26 oko kernel: [ 2796.409548]  [<ffffffff810022e1>] ? do_signal+0x51d/0x5f3
> Oct 14 00:04:26 oko kernel: [ 2796.409551]  [<ffffffff81008f1b>] ? init_fpu+0x72/0x7f
> Oct 14 00:04:26 oko kernel: [ 2796.409554]  [<ffffffff8100969f>] ? check_for_xstate+0x1c/0x6f
> Oct 14 00:04:26 oko kernel: [ 2796.409556]  [<ffffffff81009966>] ? restore_i387_xstate+0x9e/0x17c
> Oct 14 00:04:26 oko kernel: [ 2796.409559]  [<ffffffff81044e92>] ? do_sigaltstack+0xaa/0x13e
> Oct 14 00:04:26 oko kernel: [ 2796.409564]  [<ffffffff812233c5>] ? sys_sendmsg+0x39/0x58
> Oct 14 00:04:26 oko kernel: [ 2796.409568]  [<ffffffff812ec17b>] ? system_call_fastpath+0x16/0x1b
> Oct 14 00:04:26 oko kernel: [ 2796.409570] ---[ end trace 634279251cfb99d3 ]---
> Oct 14 00:04:26 oko kernel: [ 2796.409586] cfg80211: Calling CRDA for country: PL
> Oct 14 00:04:27 oko kernel: [ 2796.573759] ------------[ cut here ]------------
> Oct 14 00:04:27 oko kernel: [ 2796.575276] WARNING: at /usr/src/linux-git/drivers/net/wireless/iwlwifi/iwl-agn-lib.c:1766 iwlagn_set_rxon_chain+0x107/0x1b2 [iwlagn]()
> Oct 14 00:04:27 oko kernel: [ 2796.576866] Hardware name: Vostro 3350
> Oct 14 00:04:27 oko kernel: [ 2796.578449] invalid SMPS mode 0
> Oct 14 00:04:27 oko kernel: [ 2796.578488] Modules linked in: acpi_cpufreq mperf cpufreq_conservative autofs4 rfcomm cpufreq_stats bnep cpufreq_powersave cpufreq_userspace pci_stub binfmt_misc microcode uinput nfs lockd auth_rpcgss nfs_acl sunrpc ext2 coretemp loop kvm_intel kvm aesni_intel cryptd aes_x86_64 aes_generic ecb btusb radeon bluetooth uvcvideo usb_storage videodev arc4 media uas iwlagn v4l2_compat_ioctl32 i915 crc16 snd_hda_codec_idt ttm drm_kms_helper mac80211 drm snd_hda_intel snd_hda_codec ehci_hcd snd_hwdep xhci_hcd snd_pcm snd_seq usbcore joydev sg cfg80211 snd_timer sr_mod snd_seq_device snd r8169 psmouse dell_wmi cdrom dell_laptop soundcore i2c_algo_bit pcspkr evdev sparse_keymap processor snd_page_alloc video cfbcopyarea mii dcdbas button cfbimgblt cfbfillrect wmi ac 
 battery ext3 jbd mbcache dm_mod sd_mod crc_t10dif ahci libahci libata scsi_mod thermal thermal_sys [last unloaded: vboxdrv]
> Oct 14 00:04:27 oko kernel: [ 2796.591110] Pid: 2973, comm: NetworkManager Tainted: G        W   3.1.0-rc9+ #12
> Oct 14 00:04:27 oko kernel: [ 2796.592295] Call Trace:
> Oct 14 00:04:27 oko kernel: [ 2796.593474]  [<ffffffff8103437f>] ? warn_slowpath_common+0x78/0x8c
> Oct 14 00:04:27 oko kernel: [ 2796.594693]  [<ffffffff8103442b>] ? warn_slowpath_fmt+0x45/0x4a
> Oct 14 00:04:27 oko kernel: [ 2796.595910]  [<ffffffff812e96ed>] ? sub_preempt_count+0x83/0x94
> Oct 14 00:04:27 oko kernel: [ 2796.597087]  [<ffffffffa03a93f1>] ? iwlagn_set_rxon_chain+0x107/0x1b2 [iwlagn]
> Oct 14 00:04:27 oko kernel: [ 2796.598296]  [<ffffffff812e6f14>] ? _raw_spin_unlock_irq+0x23/0x2f
> Oct 14 00:04:27 oko kernel: [ 2796.599507]  [<ffffffffa03adc8c>] ? iwl_teardown_interface+0x4a/0x7e [iwlagn]
> Oct 14 00:04:27 oko kernel: [ 2796.600697]  [<ffffffffa03ae569>] ? iwl_mac_remove_interface+0x4e/0x5e [iwlagn]
> Oct 14 00:04:27 oko kernel: [ 2796.601914]  [<ffffffffa031c3f3>] ? ieee80211_do_stop+0x314/0x465 [mac80211]
> Oct 14 00:04:27 oko kernel: [ 2796.603133]  [<ffffffff81039618>] ? _local_bh_enable_ip.isra.12+0x94/0xa2
> Oct 14 00:04:27 oko kernel: [ 2796.604328]  [<ffffffffa031c557>] ? ieee80211_stop+0x13/0x17 [mac80211]
> Oct 14 00:04:27 oko kernel: [ 2796.605523]  [<ffffffff8122f754>] ? __dev_close_many+0x7f/0xab
> Oct 14 00:04:27 oko kernel: [ 2796.606752]  [<ffffffff8122f7b0>] ? __dev_close+0x30/0x47
> Oct 14 00:04:27 oko kernel: [ 2796.607981]  [<ffffffff812e96ed>] ? sub_preempt_count+0x83/0x94
> Oct 14 00:04:27 oko kernel: [ 2796.609179]  [<ffffffff81233e6a>] ? __dev_change_flags+0x9d/0x118
> Oct 14 00:04:27 oko kernel: [ 2796.610406]  [<ffffffff81233f4b>] ? dev_change_flags+0x12/0x42
> Oct 14 00:04:27 oko kernel: [ 2796.611639]  [<ffffffff8123da18>] ? do_setlink+0x287/0x6f8
> Oct 14 00:04:27 oko kernel: [ 2796.612848]  [<ffffffff810da6a2>] ? __kmalloc_node_track_caller+0xcb/0x105
> Oct 14 00:04:27 oko kernel: [ 2796.614089]  [<ffffffff812263ef>] ? sock_rmalloc+0x2b/0x4b
> Oct 14 00:04:27 oko kernel: [ 2796.615338]  [<ffffffff8123e20a>] ? __rtnl_unlock+0xc/0xc
> Oct 14 00:04:27 oko kernel: [ 2796.616549]  [<ffffffff8123e0d2>] ? rtnl_setlink+0xc4/0xe6
> Oct 14 00:04:27 oko kernel: [ 2796.617799]  [<ffffffff81250a06>] ? netlink_rcv_skb+0x36/0x7a
> Oct 14 00:04:27 oko kernel: [ 2796.619042]  [<ffffffff8123d64d>] ? rtnetlink_rcv+0x1f/0x28
> Oct 14 00:04:27 oko kernel: [ 2796.620261]  [<ffffffff81250537>] ? netlink_unicast+0xe6/0x14e
> Oct 14 00:04:27 oko kernel: [ 2796.621476]  [<ffffffff81250819>] ? netlink_sendmsg+0x27a/0x2b2
> Oct 14 00:04:27 oko kernel: [ 2796.622718]  [<ffffffff8122172d>] ? sock_sendmsg+0xc1/0xde
> Oct 14 00:04:27 oko kernel: [ 2796.623961]  [<ffffffff8122160e>] ? sock_recvmsg+0xcd/0xec
> Oct 14 00:04:27 oko kernel: [ 2796.625173]  [<ffffffff8122172d>] ? sock_sendmsg+0xc1/0xde
> Oct 14 00:04:27 oko kernel: [ 2796.626407]  [<ffffffff8116d88c>] ? cpumask_any_but+0x24/0x34
> Oct 14 00:04:27 oko kernel: [ 2796.627641]  [<ffffffff812228d4>] ? move_addr_to_kernel+0x24/0x46
> Oct 14 00:04:27 oko kernel: [ 2796.628853]  [<ffffffff812219c5>] ? __sys_sendmsg+0x1e8/0x288
> Oct 14 00:04:27 oko kernel: [ 2796.630089]  [<ffffffff812df81a>] ? __bad_area_nosemaphore+0x87/0x1f0
> Oct 14 00:04:27 oko kernel: [ 2796.631335]  [<ffffffff810e79c6>] ? fget_light+0x85/0x8d
> Oct 14 00:04:27 oko kernel: [ 2796.632537]  [<ffffffff812230a0>] ? sys_sendto+0x108/0x137
> Oct 14 00:04:27 oko kernel: [ 2796.633768]  [<ffffffff810f6c44>] ? dput+0xe6/0xf3
> Oct 14 00:04:27 oko kernel: [ 2796.634992]  [<ffffffff812233c5>] ? sys_sendmsg+0x39/0x58
> Oct 14 00:04:27 oko kernel: [ 2796.636194]  [<ffffffff812ec17b>] ? system_call_fastpath+0x16/0x1b
> Oct 14 00:04:27 oko kernel: [ 2796.637398] ---[ end trace 634279251cfb99d4 ]---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=-ddehr5Uv/cMFiUd8MalR
Content-Disposition: attachment; filename="0001-iwlagn-check-for-SMPS-mode.patch"
Content-Type: text/x-patch; name="0001-iwlagn-check-for-SMPS-mode.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From d52f49a327e7bfb4d07b056e16312ffd23477b8e Mon Sep 17 00:00:00 2001
From: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Date: Fri, 14 Oct 2011 08:26:07 -0700
Subject: [PATCH 1/1] iwlagn: check for SMPS mode

Check and report WARN only when its invalid

Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index 1a52ed2..6465983 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -827,6 +827,7 @@ static int iwl_get_idle_rx_chain_count(struct iwl_priv *priv, int active_cnt)
 	case IEEE80211_SMPS_STATIC:
 	case IEEE80211_SMPS_DYNAMIC:
 		return IWL_NUM_IDLE_CHAINS_SINGLE;
+	case IEEE80211_SMPS_AUTOMATIC:
 	case IEEE80211_SMPS_OFF:
 		return active_cnt;
 	default:
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
index a580efe..94c7779 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -541,6 +541,9 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 
 	mutex_lock(&priv->shrd->mutex);
 
+	if (test_bit(STATUS_EXIT_PENDING, &priv->shrd->status))
+		goto out;
+
 	if (unlikely(test_bit(STATUS_SCANNING, &priv->shrd->status))) {
 		IWL_DEBUG_MAC80211(priv, "leave - scanning\n");
 		goto out;
-- 
1.7.0.4


--=-ddehr5Uv/cMFiUd8MalR--
