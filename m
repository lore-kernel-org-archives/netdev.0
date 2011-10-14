From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: iwlagn: WARN_ON() in iwl_get_idle_rx_chain_count()
Date: Fri, 14 Oct 2011 17:02:20 +0200
Message-ID: <20111014150219.GA20672@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Intel Linux Wireless <ilw@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58646 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412Ab1JNPCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 11:02:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARN_ON() in iwl_get_idle_rx_chain_count() gets triggered on system shu=
tdown
when WiFi card is associated to an AP. This is on kernel built from
Linus' tree, commit 37cf95162af4036b4198756a590aab8126fa2ce4 (3.1.0-rc9=
+).
It looks HT-related, I can't reproduce this on 802.11g network.

Best Regards,
Micha=B3 Miros=B3aw


09:00.0 Network controller: Intel Corporation Centrino Wireless-N 1030 =
(rev 34)
        Subsystem: Intel Corporation Centrino Wireless-N 1030 BGN
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 52
        Region 0: Memory at f7a00000 (64-bit, non-prefetchable) [size=3D=
8K]
        Capabilities: <access denied>
        Kernel driver in use: iwlagn

Oct 14 00:04:26 oko kernel: [ 2796.354030] ------------[ cut here ]----=
--------
Oct 14 00:04:26 oko kernel: [ 2796.354996] WARNING: at /usr/src/linux-g=
it/drivers/net/wireless/iwlwifi/iwl-agn-lib.c:1766 iwlagn_set_rxon_chai=
n+0x107/0x1b2 [iwlagn]()
Oct 14 00:04:26 oko kernel: [ 2796.355955] Hardware name: Vostro 3350
Oct 14 00:04:26 oko kernel: [ 2796.356906] invalid SMPS mode 0
Oct 14 00:04:26 oko kernel: [ 2796.356920] Modules linked in: acpi_cpuf=
req mperf cpufreq_conservative autofs4 rfcomm cpufreq_stats bnep cpufre=
q_powersave cpufreq_userspace pci_stub binfmt_misc microcode uinput nfs=
 lockd auth_rpcgss nfs_acl sunrpc ext2 coretemp loop kvm_intel kvm aesn=
i_intel cryptd aes_x86_64 aes_generic ecb btusb radeon bluetooth uvcvid=
eo usb_storage videodev arc4 media uas iwlagn v4l2_compat_ioctl32 i915 =
crc16 snd_hda_codec_idt ttm drm_kms_helper mac80211 drm snd_hda_intel s=
nd_hda_codec ehci_hcd snd_hwdep xhci_hcd snd_pcm snd_seq usbcore joydev=
 sg cfg80211 snd_timer sr_mod snd_seq_device snd r8169 psmouse dell_wmi=
 cdrom dell_laptop soundcore i2c_algo_bit pcspkr evdev sparse_keymap pr=
ocessor snd_page_alloc video cfbcopyarea mii dcdbas button cfbimgblt cf=
bfillrect wmi ac battery ext3 jbd mbcache dm_mod sd_mod crc_t10dif ahci=
 libahci libata scsi_mod thermal thermal_sys [last unloaded: vboxdrv]
Oct 14 00:04:26 oko kernel: [ 2796.365031] Pid: 3017, comm: wpa_supplic=
ant Not tainted 3.1.0-rc9+ #12
Oct 14 00:04:26 oko kernel: [ 2796.366263] Call Trace:
Oct 14 00:04:26 oko kernel: [ 2796.367490]  [<ffffffff8103437f>] ? warn=
_slowpath_common+0x78/0x8c
Oct 14 00:04:26 oko kernel: [ 2796.368673]  [<ffffffff8103442b>] ? warn=
_slowpath_fmt+0x45/0x4a
Oct 14 00:04:26 oko kernel: [ 2796.369836]  [<ffffffffa0310733>] ? __st=
a_info_destroy+0x267/0x2af [mac80211]
Oct 14 00:04:26 oko kernel: [ 2796.371046]  [<ffffffffa03a93f1>] ? iwla=
gn_set_rxon_chain+0x107/0x1b2 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.372274]  [<ffffffffa03b2f9e>] ? iwla=
gn_bss_info_changed+0x245/0x4b3 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.373753]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.374990]  [<ffffffffa031c03a>] ? __ie=
ee80211_recalc_idle+0xef/0x194 [mac80211]
Oct 14 00:04:26 oko kernel: [ 2796.376272]  [<ffffffffa031cbee>] ? ieee=
80211_recalc_idle+0x1e/0x42 [mac80211]
Oct 14 00:04:26 oko kernel: [ 2796.377506]  [<ffffffffa0319690>] ? ieee=
80211_mgd_deauth+0x19c/0x1c0 [mac80211]
Oct 14 00:04:26 oko kernel: [ 2796.378771]  [<ffffffff812e96ed>] ? sub_=
preempt_count+0x83/0x94
Oct 14 00:04:26 oko kernel: [ 2796.380083]  [<ffffffffa01ca76c>] ? __cf=
g80211_mlme_deauth+0x107/0x116 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.381293]  [<ffffffff812e64d9>] ? sche=
dule_hrtimeout_range_clock+0xc8/0x103
Oct 14 00:04:26 oko kernel: [ 2796.382550]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.383803]  [<ffffffffa01ca7e4>] ? cfg8=
0211_mlme_deauth+0x69/0x82 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.385039]  [<ffffffff81023735>] ? __wa=
ke_up_common+0x40/0x77
Oct 14 00:04:26 oko kernel: [ 2796.386309]  [<ffffffffa01c15ed>] ? nl80=
211_deauthenticate+0xbc/0xc7 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.387607]  [<ffffffffa01c35cb>] ? nl80=
211_pre_doit+0x85/0xfb [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.389171]  [<ffffffff81250f71>] ? genl=
_rcv_msg+0x1cb/0x1f9
Oct 14 00:04:26 oko kernel: [ 2796.390753]  [<ffffffff81250da6>] ? genl=
_rcv+0x28/0x28
Oct 14 00:04:26 oko kernel: [ 2796.392295]  [<ffffffff81250a06>] ? netl=
ink_rcv_skb+0x36/0x7a
Oct 14 00:04:26 oko kernel: [ 2796.393896]  [<ffffffff81250d9d>] ? genl=
_rcv+0x1f/0x28
Oct 14 00:04:26 oko kernel: [ 2796.395521]  [<ffffffff81250537>] ? netl=
ink_unicast+0xe6/0x14e
Oct 14 00:04:26 oko kernel: [ 2796.397095]  [<ffffffff81250819>] ? netl=
ink_sendmsg+0x27a/0x2b2
Oct 14 00:04:26 oko kernel: [ 2796.398741]  [<ffffffff810f45dc>] ? __po=
llwait+0xce/0xce
Oct 14 00:04:26 oko kernel: [ 2796.400378]  [<ffffffff8122172d>] ? sock=
_sendmsg+0xc1/0xde
Oct 14 00:04:26 oko kernel: [ 2796.402042]  [<ffffffff8122160e>] ? sock=
_recvmsg+0xcd/0xec
Oct 14 00:04:26 oko kernel: [ 2796.403645]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.405148]  [<ffffffff8122160e>] ? sock=
_recvmsg+0xcd/0xec
Oct 14 00:04:26 oko kernel: [ 2796.406650]  [<ffffffff812228d4>] ? move=
_addr_to_kernel+0x24/0x46
Oct 14 00:04:26 oko kernel: [ 2796.408098]  [<ffffffff812219c5>] ? __sy=
s_sendmsg+0x1e8/0x288
Oct 14 00:04:26 oko kernel: [ 2796.408102]  [<ffffffff812e9798>] ? add_=
preempt_count+0x9a/0x9c
Oct 14 00:04:26 oko kernel: [ 2796.408107]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.408109]  [<ffffffff812e96ed>] ? sub_=
preempt_count+0x83/0x94
Oct 14 00:04:26 oko kernel: [ 2796.408112]  [<ffffffff812e6f14>] ? _raw=
_spin_unlock_irq+0x23/0x2f
Oct 14 00:04:26 oko kernel: [ 2796.408115]  [<ffffffff810022e1>] ? do_s=
ignal+0x51d/0x5f3
Oct 14 00:04:26 oko kernel: [ 2796.408119]  [<ffffffff81008f1b>] ? init=
_fpu+0x72/0x7f
Oct 14 00:04:26 oko kernel: [ 2796.408122]  [<ffffffff8100969f>] ? chec=
k_for_xstate+0x1c/0x6f
Oct 14 00:04:26 oko kernel: [ 2796.408124]  [<ffffffff81009966>] ? rest=
ore_i387_xstate+0x9e/0x17c
Oct 14 00:04:26 oko kernel: [ 2796.408128]  [<ffffffff81044e92>] ? do_s=
igaltstack+0xaa/0x13e
Oct 14 00:04:26 oko kernel: [ 2796.408131]  [<ffffffff812233c5>] ? sys_=
sendmsg+0x39/0x58
Oct 14 00:04:26 oko kernel: [ 2796.408134]  [<ffffffff812ec17b>] ? syst=
em_call_fastpath+0x16/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.408176] ---[ end trace 634279251cfb9=
9d1 ]---
Oct 14 00:04:26 oko kernel: [ 2796.409026] ------------[ cut here ]----=
--------
Oct 14 00:04:26 oko kernel: [ 2796.409046] WARNING: at /usr/src/linux-g=
it/drivers/net/wireless/iwlwifi/iwl-agn-lib.c:1766 iwlagn_set_rxon_chai=
n+0x107/0x1b2 [iwlagn]()
Oct 14 00:04:26 oko kernel: [ 2796.409048] Hardware name: Vostro 3350
Oct 14 00:04:26 oko kernel: [ 2796.409049] invalid SMPS mode 0
Oct 14 00:04:26 oko kernel: [ 2796.409050] Modules linked in: acpi_cpuf=
req mperf cpufreq_conservative autofs4 rfcomm cpufreq_stats bnep cpufre=
q_powersave cpufreq_userspace pci_stub binfmt_misc microcode uinput nfs=
 lockd auth_rpcgss nfs_acl sunrpc ext2 coretemp loop kvm_intel kvm aesn=
i_intel cryptd aes_x86_64 aes_generic ecb btusb radeon bluetooth uvcvid=
eo usb_storage videodev arc4 media uas iwlagn v4l2_compat_ioctl32 i915 =
crc16 snd_hda_codec_idt ttm drm_kms_helper mac80211 drm snd_hda_intel s=
nd_hda_codec ehci_hcd snd_hwdep xhci_hcd snd_pcm snd_seq usbcore joydev=
 sg cfg80211 snd_timer sr_mod snd_seq_device snd r8169 psmouse dell_wmi=
 cdrom dell_laptop soundcore i2c_algo_bit pcspkr evdev sparse_keymap pr=
ocessor snd_page_alloc video cfbcopyarea mii dcdbas button cfbimgblt cf=
bfillrect wmi ac battery ext3 jbd mbcache dm_mod sd_mod crc_t10dif ahci=
 libahci libata scsi_mod thermal thermal_sys [last unloaded: vboxdrv]
Oct 14 00:04:26 oko kernel: [ 2796.409109] Pid: 3017, comm: wpa_supplic=
ant Tainted: G        W   3.1.0-rc9+ #12
Oct 14 00:04:26 oko kernel: [ 2796.409110] Call Trace:
Oct 14 00:04:26 oko kernel: [ 2796.409116]  [<ffffffff8103437f>] ? warn=
_slowpath_common+0x78/0x8c
Oct 14 00:04:26 oko kernel: [ 2796.409119]  [<ffffffff8103442b>] ? warn=
_slowpath_fmt+0x45/0x4a
Oct 14 00:04:26 oko kernel: [ 2796.409133]  [<ffffffffa03b78e7>] ? iwl_=
send_cmd+0x1a4/0x303 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409140]  [<ffffffffa03a93f1>] ? iwla=
gn_set_rxon_chain+0x107/0x1b2 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409145]  [<ffffffffa03a276d>] ? iwl_=
update_chain_flags+0x32/0x58 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409156]  [<ffffffffa03af7cd>] ? iwl_=
power_set_mode+0xf4/0x157 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409163]  [<ffffffffa03af9e0>] ? iwl_=
power_update_mode+0x1b0/0x1b9 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409170]  [<ffffffffa03b2cd8>] ? iwla=
gn_mac_config+0x206/0x287 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409185]  [<ffffffffa0319690>] ? ieee=
80211_mgd_deauth+0x19c/0x1c0 [mac80211]
Oct 14 00:04:26 oko kernel: [ 2796.409188]  [<ffffffff812e96ed>] ? sub_=
preempt_count+0x83/0x94
Oct 14 00:04:26 oko kernel: [ 2796.409201]  [<ffffffffa01ca76c>] ? __cf=
g80211_mlme_deauth+0x107/0x116 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.409206]  [<ffffffff812e64d9>] ? sche=
dule_hrtimeout_range_clock+0xc8/0x103
Oct 14 00:04:26 oko kernel: [ 2796.409208]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.409216]  [<ffffffffa01ca7e4>] ? cfg8=
0211_mlme_deauth+0x69/0x82 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.409220]  [<ffffffff81023735>] ? __wa=
ke_up_common+0x40/0x77
Oct 14 00:04:26 oko kernel: [ 2796.409228]  [<ffffffffa01c15ed>] ? nl80=
211_deauthenticate+0xbc/0xc7 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.409238]  [<ffffffffa01c35cb>] ? nl80=
211_pre_doit+0x85/0xfb [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.409244]  [<ffffffff81250f71>] ? genl=
_rcv_msg+0x1cb/0x1f9
Oct 14 00:04:26 oko kernel: [ 2796.409246]  [<ffffffff81250da6>] ? genl=
_rcv+0x28/0x28
Oct 14 00:04:26 oko kernel: [ 2796.409249]  [<ffffffff81250a06>] ? netl=
ink_rcv_skb+0x36/0x7a
Oct 14 00:04:26 oko kernel: [ 2796.409251]  [<ffffffff81250d9d>] ? genl=
_rcv+0x1f/0x28
Oct 14 00:04:26 oko kernel: [ 2796.409253]  [<ffffffff81250537>] ? netl=
ink_unicast+0xe6/0x14e
Oct 14 00:04:26 oko kernel: [ 2796.409256]  [<ffffffff81250819>] ? netl=
ink_sendmsg+0x27a/0x2b2
Oct 14 00:04:26 oko kernel: [ 2796.409262]  [<ffffffff810f45dc>] ? __po=
llwait+0xce/0xce
Oct 14 00:04:26 oko kernel: [ 2796.409266]  [<ffffffff8122172d>] ? sock=
_sendmsg+0xc1/0xde
Oct 14 00:04:26 oko kernel: [ 2796.409268]  [<ffffffff8122160e>] ? sock=
_recvmsg+0xcd/0xec
Oct 14 00:04:26 oko kernel: [ 2796.409271]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.409273]  [<ffffffff8122160e>] ? sock=
_recvmsg+0xcd/0xec
Oct 14 00:04:26 oko kernel: [ 2796.409276]  [<ffffffff812228d4>] ? move=
_addr_to_kernel+0x24/0x46
Oct 14 00:04:26 oko kernel: [ 2796.409279]  [<ffffffff812219c5>] ? __sy=
s_sendmsg+0x1e8/0x288
Oct 14 00:04:26 oko kernel: [ 2796.409282]  [<ffffffff812e9798>] ? add_=
preempt_count+0x9a/0x9c
Oct 14 00:04:26 oko kernel: [ 2796.409284]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.409286]  [<ffffffff812e96ed>] ? sub_=
preempt_count+0x83/0x94
Oct 14 00:04:26 oko kernel: [ 2796.409289]  [<ffffffff812e6f14>] ? _raw=
_spin_unlock_irq+0x23/0x2f
Oct 14 00:04:26 oko kernel: [ 2796.409294]  [<ffffffff810022e1>] ? do_s=
ignal+0x51d/0x5f3
Oct 14 00:04:26 oko kernel: [ 2796.409297]  [<ffffffff81008f1b>] ? init=
_fpu+0x72/0x7f
Oct 14 00:04:26 oko kernel: [ 2796.409300]  [<ffffffff8100969f>] ? chec=
k_for_xstate+0x1c/0x6f
Oct 14 00:04:26 oko kernel: [ 2796.409303]  [<ffffffff81009966>] ? rest=
ore_i387_xstate+0x9e/0x17c
Oct 14 00:04:26 oko kernel: [ 2796.409305]  [<ffffffff81044e92>] ? do_s=
igaltstack+0xaa/0x13e
Oct 14 00:04:26 oko kernel: [ 2796.409308]  [<ffffffff812233c5>] ? sys_=
sendmsg+0x39/0x58
Oct 14 00:04:26 oko kernel: [ 2796.409312]  [<ffffffff812ec17b>] ? syst=
em_call_fastpath+0x16/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.409314] ---[ end trace 634279251cfb9=
9d2 ]---
Oct 14 00:04:26 oko kernel: [ 2796.409315] ------------[ cut here ]----=
--------
Oct 14 00:04:26 oko kernel: [ 2796.409325] WARNING: at /usr/src/linux-g=
it/drivers/net/wireless/iwlwifi/iwl-agn-lib.c:1766 iwlagn_set_rxon_chai=
n+0x107/0x1b2 [iwlagn]()
Oct 14 00:04:26 oko kernel: [ 2796.409327] Hardware name: Vostro 3350
Oct 14 00:04:26 oko kernel: [ 2796.409328] invalid SMPS mode 0
Oct 14 00:04:26 oko kernel: [ 2796.409329] Modules linked in: acpi_cpuf=
req mperf cpufreq_conservative autofs4 rfcomm cpufreq_stats bnep cpufre=
q_powersave cpufreq_userspace pci_stub binfmt_misc microcode uinput nfs=
 lockd auth_rpcgss nfs_acl sunrpc ext2 coretemp loop kvm_intel kvm aesn=
i_intel cryptd aes_x86_64 aes_generic ecb btusb radeon bluetooth uvcvid=
eo usb_storage videodev arc4 media uas iwlagn v4l2_compat_ioctl32 i915 =
crc16 snd_hda_codec_idt ttm drm_kms_helper mac80211 drm snd_hda_intel s=
nd_hda_codec ehci_hcd snd_hwdep xhci_hcd snd_pcm snd_seq usbcore joydev=
 sg cfg80211 snd_timer sr_mod snd_seq_device snd r8169 psmouse dell_wmi=
 cdrom dell_laptop soundcore i2c_algo_bit pcspkr evdev sparse_keymap pr=
ocessor snd_page_alloc video cfbcopyarea mii dcdbas button cfbimgblt cf=
bfillrect wmi ac battery ext3 jbd mbcache dm_mod sd_mod crc_t10dif ahci=
 libahci libata scsi_mod thermal thermal_sys [last unloaded: vboxdrv]
Oct 14 00:04:26 oko kernel: [ 2796.409371] Pid: 3017, comm: wpa_supplic=
ant Tainted: G        W   3.1.0-rc9+ #12
Oct 14 00:04:26 oko kernel: [ 2796.409372] Call Trace:
Oct 14 00:04:26 oko kernel: [ 2796.409381]  [<ffffffff8103437f>] ? warn=
_slowpath_common+0x78/0x8c
Oct 14 00:04:26 oko kernel: [ 2796.409384]  [<ffffffff8103442b>] ? warn=
_slowpath_fmt+0x45/0x4a
Oct 14 00:04:26 oko kernel: [ 2796.409392]  [<ffffffffa03b78e7>] ? iwl_=
send_cmd+0x1a4/0x303 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409399]  [<ffffffffa03a93f1>] ? iwla=
gn_set_rxon_chain+0x107/0x1b2 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409408]  [<ffffffffa03a276d>] ? iwl_=
update_chain_flags+0x32/0x58 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409415]  [<ffffffffa03af7cd>] ? iwl_=
power_set_mode+0xf4/0x157 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409421]  [<ffffffffa03af9e0>] ? iwl_=
power_update_mode+0x1b0/0x1b9 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409429]  [<ffffffffa03b2cd8>] ? iwla=
gn_mac_config+0x206/0x287 [iwlagn]
Oct 14 00:04:26 oko kernel: [ 2796.409439]  [<ffffffffa0319690>] ? ieee=
80211_mgd_deauth+0x19c/0x1c0 [mac80211]
Oct 14 00:04:26 oko kernel: [ 2796.409442]  [<ffffffff812e96ed>] ? sub_=
preempt_count+0x83/0x94
Oct 14 00:04:26 oko kernel: [ 2796.409457]  [<ffffffffa01ca76c>] ? __cf=
g80211_mlme_deauth+0x107/0x116 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.409460]  [<ffffffff812e64d9>] ? sche=
dule_hrtimeout_range_clock+0xc8/0x103
Oct 14 00:04:26 oko kernel: [ 2796.409463]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.409477]  [<ffffffffa01ca7e4>] ? cfg8=
0211_mlme_deauth+0x69/0x82 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.409479]  [<ffffffff81023735>] ? __wa=
ke_up_common+0x40/0x77
Oct 14 00:04:26 oko kernel: [ 2796.409490]  [<ffffffffa01c15ed>] ? nl80=
211_deauthenticate+0xbc/0xc7 [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.409498]  [<ffffffffa01c35cb>] ? nl80=
211_pre_doit+0x85/0xfb [cfg80211]
Oct 14 00:04:26 oko kernel: [ 2796.409502]  [<ffffffff81250f71>] ? genl=
_rcv_msg+0x1cb/0x1f9
Oct 14 00:04:26 oko kernel: [ 2796.409505]  [<ffffffff81250da6>] ? genl=
_rcv+0x28/0x28
Oct 14 00:04:26 oko kernel: [ 2796.409507]  [<ffffffff81250a06>] ? netl=
ink_rcv_skb+0x36/0x7a
Oct 14 00:04:26 oko kernel: [ 2796.409509]  [<ffffffff81250d9d>] ? genl=
_rcv+0x1f/0x28
Oct 14 00:04:26 oko kernel: [ 2796.409511]  [<ffffffff81250537>] ? netl=
ink_unicast+0xe6/0x14e
Oct 14 00:04:26 oko kernel: [ 2796.409514]  [<ffffffff81250819>] ? netl=
ink_sendmsg+0x27a/0x2b2
Oct 14 00:04:26 oko kernel: [ 2796.409517]  [<ffffffff810f45dc>] ? __po=
llwait+0xce/0xce
Oct 14 00:04:26 oko kernel: [ 2796.409519]  [<ffffffff8122172d>] ? sock=
_sendmsg+0xc1/0xde
Oct 14 00:04:26 oko kernel: [ 2796.409521]  [<ffffffff8122160e>] ? sock=
_recvmsg+0xcd/0xec
Oct 14 00:04:26 oko kernel: [ 2796.409526]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.409529]  [<ffffffff8122160e>] ? sock=
_recvmsg+0xcd/0xec
Oct 14 00:04:26 oko kernel: [ 2796.409532]  [<ffffffff812228d4>] ? move=
_addr_to_kernel+0x24/0x46
Oct 14 00:04:26 oko kernel: [ 2796.409534]  [<ffffffff812219c5>] ? __sy=
s_sendmsg+0x1e8/0x288
Oct 14 00:04:26 oko kernel: [ 2796.409537]  [<ffffffff812e9798>] ? add_=
preempt_count+0x9a/0x9c
Oct 14 00:04:26 oko kernel: [ 2796.409539]  [<ffffffff8102c1e5>] ? get_=
parent_ip+0x9/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.409542]  [<ffffffff812e96ed>] ? sub_=
preempt_count+0x83/0x94
Oct 14 00:04:26 oko kernel: [ 2796.409544]  [<ffffffff812e6f14>] ? _raw=
_spin_unlock_irq+0x23/0x2f
Oct 14 00:04:26 oko kernel: [ 2796.409548]  [<ffffffff810022e1>] ? do_s=
ignal+0x51d/0x5f3
Oct 14 00:04:26 oko kernel: [ 2796.409551]  [<ffffffff81008f1b>] ? init=
_fpu+0x72/0x7f
Oct 14 00:04:26 oko kernel: [ 2796.409554]  [<ffffffff8100969f>] ? chec=
k_for_xstate+0x1c/0x6f
Oct 14 00:04:26 oko kernel: [ 2796.409556]  [<ffffffff81009966>] ? rest=
ore_i387_xstate+0x9e/0x17c
Oct 14 00:04:26 oko kernel: [ 2796.409559]  [<ffffffff81044e92>] ? do_s=
igaltstack+0xaa/0x13e
Oct 14 00:04:26 oko kernel: [ 2796.409564]  [<ffffffff812233c5>] ? sys_=
sendmsg+0x39/0x58
Oct 14 00:04:26 oko kernel: [ 2796.409568]  [<ffffffff812ec17b>] ? syst=
em_call_fastpath+0x16/0x1b
Oct 14 00:04:26 oko kernel: [ 2796.409570] ---[ end trace 634279251cfb9=
9d3 ]---
Oct 14 00:04:26 oko kernel: [ 2796.409586] cfg80211: Calling CRDA for c=
ountry: PL
Oct 14 00:04:27 oko kernel: [ 2796.573759] ------------[ cut here ]----=
--------
Oct 14 00:04:27 oko kernel: [ 2796.575276] WARNING: at /usr/src/linux-g=
it/drivers/net/wireless/iwlwifi/iwl-agn-lib.c:1766 iwlagn_set_rxon_chai=
n+0x107/0x1b2 [iwlagn]()
Oct 14 00:04:27 oko kernel: [ 2796.576866] Hardware name: Vostro 3350
Oct 14 00:04:27 oko kernel: [ 2796.578449] invalid SMPS mode 0
Oct 14 00:04:27 oko kernel: [ 2796.578488] Modules linked in: acpi_cpuf=
req mperf cpufreq_conservative autofs4 rfcomm cpufreq_stats bnep cpufre=
q_powersave cpufreq_userspace pci_stub binfmt_misc microcode uinput nfs=
 lockd auth_rpcgss nfs_acl sunrpc ext2 coretemp loop kvm_intel kvm aesn=
i_intel cryptd aes_x86_64 aes_generic ecb btusb radeon bluetooth uvcvid=
eo usb_storage videodev arc4 media uas iwlagn v4l2_compat_ioctl32 i915 =
crc16 snd_hda_codec_idt ttm drm_kms_helper mac80211 drm snd_hda_intel s=
nd_hda_codec ehci_hcd snd_hwdep xhci_hcd snd_pcm snd_seq usbcore joydev=
 sg cfg80211 snd_timer sr_mod snd_seq_device snd r8169 psmouse dell_wmi=
 cdrom dell_laptop soundcore i2c_algo_bit pcspkr evdev sparse_keymap pr=
ocessor snd_page_alloc video cfbcopyarea mii dcdbas button cfbimgblt cf=
bfillrect wmi ac battery ext3 jbd mbcache dm_mod sd_mod crc_t10dif ahci=
 libahci libata scsi_mod thermal thermal_sys [last unloaded: vboxdrv]
Oct 14 00:04:27 oko kernel: [ 2796.591110] Pid: 2973, comm: NetworkMana=
ger Tainted: G        W   3.1.0-rc9+ #12
Oct 14 00:04:27 oko kernel: [ 2796.592295] Call Trace:
Oct 14 00:04:27 oko kernel: [ 2796.593474]  [<ffffffff8103437f>] ? warn=
_slowpath_common+0x78/0x8c
Oct 14 00:04:27 oko kernel: [ 2796.594693]  [<ffffffff8103442b>] ? warn=
_slowpath_fmt+0x45/0x4a
Oct 14 00:04:27 oko kernel: [ 2796.595910]  [<ffffffff812e96ed>] ? sub_=
preempt_count+0x83/0x94
Oct 14 00:04:27 oko kernel: [ 2796.597087]  [<ffffffffa03a93f1>] ? iwla=
gn_set_rxon_chain+0x107/0x1b2 [iwlagn]
Oct 14 00:04:27 oko kernel: [ 2796.598296]  [<ffffffff812e6f14>] ? _raw=
_spin_unlock_irq+0x23/0x2f
Oct 14 00:04:27 oko kernel: [ 2796.599507]  [<ffffffffa03adc8c>] ? iwl_=
teardown_interface+0x4a/0x7e [iwlagn]
Oct 14 00:04:27 oko kernel: [ 2796.600697]  [<ffffffffa03ae569>] ? iwl_=
mac_remove_interface+0x4e/0x5e [iwlagn]
Oct 14 00:04:27 oko kernel: [ 2796.601914]  [<ffffffffa031c3f3>] ? ieee=
80211_do_stop+0x314/0x465 [mac80211]
Oct 14 00:04:27 oko kernel: [ 2796.603133]  [<ffffffff81039618>] ? _loc=
al_bh_enable_ip.isra.12+0x94/0xa2
Oct 14 00:04:27 oko kernel: [ 2796.604328]  [<ffffffffa031c557>] ? ieee=
80211_stop+0x13/0x17 [mac80211]
Oct 14 00:04:27 oko kernel: [ 2796.605523]  [<ffffffff8122f754>] ? __de=
v_close_many+0x7f/0xab
Oct 14 00:04:27 oko kernel: [ 2796.606752]  [<ffffffff8122f7b0>] ? __de=
v_close+0x30/0x47
Oct 14 00:04:27 oko kernel: [ 2796.607981]  [<ffffffff812e96ed>] ? sub_=
preempt_count+0x83/0x94
Oct 14 00:04:27 oko kernel: [ 2796.609179]  [<ffffffff81233e6a>] ? __de=
v_change_flags+0x9d/0x118
Oct 14 00:04:27 oko kernel: [ 2796.610406]  [<ffffffff81233f4b>] ? dev_=
change_flags+0x12/0x42
Oct 14 00:04:27 oko kernel: [ 2796.611639]  [<ffffffff8123da18>] ? do_s=
etlink+0x287/0x6f8
Oct 14 00:04:27 oko kernel: [ 2796.612848]  [<ffffffff810da6a2>] ? __km=
alloc_node_track_caller+0xcb/0x105
Oct 14 00:04:27 oko kernel: [ 2796.614089]  [<ffffffff812263ef>] ? sock=
_rmalloc+0x2b/0x4b
Oct 14 00:04:27 oko kernel: [ 2796.615338]  [<ffffffff8123e20a>] ? __rt=
nl_unlock+0xc/0xc
Oct 14 00:04:27 oko kernel: [ 2796.616549]  [<ffffffff8123e0d2>] ? rtnl=
_setlink+0xc4/0xe6
Oct 14 00:04:27 oko kernel: [ 2796.617799]  [<ffffffff81250a06>] ? netl=
ink_rcv_skb+0x36/0x7a
Oct 14 00:04:27 oko kernel: [ 2796.619042]  [<ffffffff8123d64d>] ? rtne=
tlink_rcv+0x1f/0x28
Oct 14 00:04:27 oko kernel: [ 2796.620261]  [<ffffffff81250537>] ? netl=
ink_unicast+0xe6/0x14e
Oct 14 00:04:27 oko kernel: [ 2796.621476]  [<ffffffff81250819>] ? netl=
ink_sendmsg+0x27a/0x2b2
Oct 14 00:04:27 oko kernel: [ 2796.622718]  [<ffffffff8122172d>] ? sock=
_sendmsg+0xc1/0xde
Oct 14 00:04:27 oko kernel: [ 2796.623961]  [<ffffffff8122160e>] ? sock=
_recvmsg+0xcd/0xec
Oct 14 00:04:27 oko kernel: [ 2796.625173]  [<ffffffff8122172d>] ? sock=
_sendmsg+0xc1/0xde
Oct 14 00:04:27 oko kernel: [ 2796.626407]  [<ffffffff8116d88c>] ? cpum=
ask_any_but+0x24/0x34
Oct 14 00:04:27 oko kernel: [ 2796.627641]  [<ffffffff812228d4>] ? move=
_addr_to_kernel+0x24/0x46
Oct 14 00:04:27 oko kernel: [ 2796.628853]  [<ffffffff812219c5>] ? __sy=
s_sendmsg+0x1e8/0x288
Oct 14 00:04:27 oko kernel: [ 2796.630089]  [<ffffffff812df81a>] ? __ba=
d_area_nosemaphore+0x87/0x1f0
Oct 14 00:04:27 oko kernel: [ 2796.631335]  [<ffffffff810e79c6>] ? fget=
_light+0x85/0x8d
Oct 14 00:04:27 oko kernel: [ 2796.632537]  [<ffffffff812230a0>] ? sys_=
sendto+0x108/0x137
Oct 14 00:04:27 oko kernel: [ 2796.633768]  [<ffffffff810f6c44>] ? dput=
+0xe6/0xf3
Oct 14 00:04:27 oko kernel: [ 2796.634992]  [<ffffffff812233c5>] ? sys_=
sendmsg+0x39/0x58
Oct 14 00:04:27 oko kernel: [ 2796.636194]  [<ffffffff812ec17b>] ? syst=
em_call_fastpath+0x16/0x1b
Oct 14 00:04:27 oko kernel: [ 2796.637398] ---[ end trace 634279251cfb9=
9d4 ]---
