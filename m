From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: [WARNING] v3.12-rc6-3-g0df651a WARNING: CPU: 2 PID: 6800 at
 net/wireless/chan.c:373 cfg80211_chandef_usable+0x31/0x161 [cfg80211]()
Date: Mon, 21 Oct 2013 12:21:31 +0200
Message-ID: <20131021102131.GA11265@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.glanzmann.de ([78.47.70.69]:40854 "EHLO
	infra.glanzmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461Ab3JUKVf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 06:21:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I'm referring to commit 9f5e8f6efc7c2601136b27d9c7325c245f8fd19a. I just
checked out the tip from Linus tree compiled it and run it on Debian
Wheezy with a

03:00.0 Network controller: Intel Corporation Centrino Ultimate-N 6300 (rev 35)

and configured an ad-hoc network:

iface adhoc inet static
        address 172.16.0.1
        netmask 255.255.255.0
        wireless-channel 1
        wireless-essid Glanzmann
        wireless-mode ad-hoc
        up /bin/echo 1 > /proc/sys/net/ipv4/ip_forward || true
        up /sbin/iptables -t nat -F || true
        up /sbin/iptables -t nat -A POSTROUTING -o eth0 -s 172.16.0.0/255.255.255.0 -j MASQUERADE || true

When I sto pand start the wlan0 I have the following in my dmesg:
ifup wlan0=adhoc
# wait a little bit
ifdown wlan0=adhoc
ifup wlan0=adhoc

[   83.771408] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   83.772045] wlan0: Trigger new scan to find an IBSS to join
[   83.786265] ip_tables: (C) 2000-2006 Netfilter Core Team
[   83.792356] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   83.809614] wlan0: Selected IBSS BSSID 02:19:8e:0c:80:0c based on configured SSID
[   83.840092] iwlwifi 0000:03:00.0: Unable to find TIM Element in beacon
[   83.841207] iwlwifi 0000:03:00.0: Unable to find TIM Element in beacon
[   83.841648] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[ 1719.626285] iwlwifi 0000:03:00.0: REPLY_REMOVE_STA failed
[ 1719.626294] iwlwifi 0000:03:00.0: failed to remove IBSS station 00:00:00:00:00:00
[ 1723.211138] iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
[ 1723.217777] iwlwifi 0000:03:00.0: Radio type=0x0-0x3-0x1
[ 1723.354729] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[ 1723.371674] wlan0: Trigger new scan to find an IBSS to join
[ 1726.016946] wlan0: Trigger new scan to find an IBSS to join
[ 1730.015402] wlan0: Trigger new scan to find an IBSS to join
[ 1732.004647] wlan0: Creating new IBSS network, BSSID 66:6f:67:02:c0:67
[ 1732.004656] ------------[ cut here ]------------
[ 1732.004690] WARNING: CPU: 2 PID: 6800 at net/wireless/chan.c:373 cfg80211_chandef_usable+0x31/0x161 [cfg80211]()
[ 1732.004692] Modules linked in: ipt_MASQUERADE iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack ip_tables x_tables autofs4 nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc fuse loop qcserial usb_wwan usbserial btusb bluetooth snd_hda_codec_hdmi snd_hda_codec_conexant arc4 iwldvm mac80211 thinkpad_acpi nvram iTCO_wdt iTCO_vendor_support snd_seq_midi snd_seq_midi_event mxm_wmi snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_rawmidi snd_pcm snd_page_alloc coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel snd_seq snd_timer snd_seq_device snd aesni_intel ac pcspkr psmouse aes_x86_64 ablk_helper battery cryptd serio_raw lrw tpm_tis gf128mul tpm glue_helper tpm_bios evdev i915 iwlwifi wmi drm_kms_helper video intel_ips drm i2c_
 algo_bit soundcore cfg80211 ehci_pci i2c_i801 ehci_hcd lpc_ich i2c_core mfd_core rfkill usbcore usb_common acpi_cpufreq button processor ext4 crc16 jbd2 mbcache sg sd_mod sr_mod crc_t10dif cdrom crct10dif_common microcode ahci libahci libata scsi_mod thermal thermal_sys sdhci_pci sdhci mmc_core e1000e ptp pps_core
[ 1732.004790] CPU: 2 PID: 6800 Comm: kworker/u8:2 Not tainted 3.12.0-rc6+ #3
[ 1732.004792] Hardware name: LENOVO 2912W1C/2912W1C, BIOS 6UET70WW (1.50 ) 10/11/2012
[ 1732.004808] Workqueue: phy0 ieee80211_iface_work [mac80211]
[ 1732.004811]  0000000000000000 0000000000000009 ffffffff81373aba 0000000000000000
[ 1732.004816]  ffffffff8103732b 0000000000000002 ffffffffa02663ca 0000000000000000
[ 1732.004820]  000000000000000f ffff8800b4818220 ffff8800af03dd70 ffff8800b4818220
[ 1732.004825] Call Trace:
[ 1732.004834]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[ 1732.004840]  [<ffffffff8103732b>] ? warn_slowpath_common+0x78/0x90
[ 1732.004855]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1732.004868]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1732.004881]  [<ffffffffa026653a>] ? cfg80211_reg_can_beacon+0x40/0x90 [cfg80211]
[ 1732.004895]  [<ffffffffa0523bc3>] ? __ieee80211_sta_join_ibss+0x15b/0x6e7 [mac80211]
[ 1732.004900]  [<ffffffff81371724>] ? printk+0x4f/0x54
[ 1732.004912]  [<ffffffffa0524217>] ? ieee80211_sta_create_ibss+0xc8/0xce [mac80211]
[ 1732.004926]  [<ffffffffa0524f9d>] ? ieee80211_ibss_work+0x250/0x3c0 [mac80211]
[ 1732.004930]  [<ffffffff8104b960>] ? process_one_work+0x191/0x294
[ 1732.004934]  [<ffffffff8104be12>] ? worker_thread+0x121/0x1e7
[ 1732.004938]  [<ffffffff8104bcf1>] ? rescuer_thread+0x269/0x269
[ 1732.004942]  [<ffffffff81050819>] ? kthread+0x81/0x89
[ 1732.004947]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1732.004953]  [<ffffffff8137c83c>] ? ret_from_fork+0x7c/0xb0
[ 1732.004957]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1732.004960] ---[ end trace 426d84b14a51a2b7 ]---
[ 1732.004963] wlan0: Failed to join IBSS, beacons forbidden
[ 1733.993860] wlan0: Trigger new scan to find an IBSS to join
[ 1734.015429] wlan0: Creating new IBSS network, BSSID 46:09:3a:82:f0:54
[ 1734.025897] ------------[ cut here ]------------
[ 1734.025932] WARNING: CPU: 2 PID: 6800 at net/wireless/chan.c:373 cfg80211_chandef_usable+0x31/0x161 [cfg80211]()
[ 1734.025935] Modules linked in: ipt_MASQUERADE iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack ip_tables x_tables autofs4 nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc fuse loop qcserial usb_wwan usbserial btusb bluetooth snd_hda_codec_hdmi snd_hda_codec_conexant arc4 iwldvm mac80211 thinkpad_acpi nvram iTCO_wdt iTCO_vendor_support snd_seq_midi snd_seq_midi_event mxm_wmi snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_rawmidi snd_pcm snd_page_alloc coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel snd_seq snd_timer snd_seq_device snd aesni_intel ac pcspkr psmouse aes_x86_64 ablk_helper battery cryptd serio_raw lrw tpm_tis gf128mul tpm glue_helper tpm_bios evdev i915 iwlwifi wmi drm_kms_helper video intel_ips drm i2c_
 algo_bit soundcore cfg80211 ehci_pci i2c_i801 ehci_hcd lpc_ich i2c_core mfd_core rfkill usbcore usb_common acpi_cpufreq button processor ext4 crc16 jbd2 mbcache sg sd_mod sr_mod crc_t10dif cdrom crct10dif_common microcode ahci libahci libata scsi_mod thermal thermal_sys sdhci_pci sdhci mmc_core e1000e ptp pps_core
[ 1734.026032] CPU: 2 PID: 6800 Comm: kworker/u8:2 Tainted: G        W    3.12.0-rc6+ #3
[ 1734.026035] Hardware name: LENOVO 2912W1C/2912W1C, BIOS 6UET70WW (1.50 ) 10/11/2012
[ 1734.026052] Workqueue: phy0 ieee80211_iface_work [mac80211]
[ 1734.026055]  0000000000000000 0000000000000009 ffffffff81373aba 0000000000000000
[ 1734.026060]  ffffffff8103732b 0000000000000001 ffffffffa02663ca ffff8800373577b0
[ 1734.026064]  000000000000000f ffff8800b4818220 ffff8800af03dd70 ffff8800b4818220
[ 1734.026069] Call Trace:
[ 1734.026078]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[ 1734.026085]  [<ffffffff8103732b>] ? warn_slowpath_common+0x78/0x90
[ 1734.026099]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1734.026112]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1734.026125]  [<ffffffffa026653a>] ? cfg80211_reg_can_beacon+0x40/0x90 [cfg80211]
[ 1734.026139]  [<ffffffffa0523bc3>] ? __ieee80211_sta_join_ibss+0x15b/0x6e7 [mac80211]
[ 1734.026144]  [<ffffffff81371724>] ? printk+0x4f/0x54
[ 1734.026157]  [<ffffffffa0524217>] ? ieee80211_sta_create_ibss+0xc8/0xce [mac80211]
[ 1734.026170]  [<ffffffffa0524f9d>] ? ieee80211_ibss_work+0x250/0x3c0 [mac80211]
[ 1734.026175]  [<ffffffff8104b960>] ? process_one_work+0x191/0x294
[ 1734.026179]  [<ffffffff8104be12>] ? worker_thread+0x121/0x1e7
[ 1734.026182]  [<ffffffff8104bcf1>] ? rescuer_thread+0x269/0x269
[ 1734.026189]  [<ffffffff81050819>] ? kthread+0x81/0x89
[ 1734.026193]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1734.026198]  [<ffffffff8137c83c>] ? ret_from_fork+0x7c/0xb0
[ 1734.026203]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1734.026206] ---[ end trace 426d84b14a51a2b8 ]---
[ 1734.026208] wlan0: Failed to join IBSS, beacons forbidden
[ 1735.995111] wlan0: Creating new IBSS network, BSSID 76:28:a9:0d:88:36
[ 1736.011157] ------------[ cut here ]------------
[ 1736.011185] WARNING: CPU: 1 PID: 6800 at net/wireless/chan.c:373 cfg80211_chandef_usable+0x31/0x161 [cfg80211]()
[ 1736.011188] Modules linked in: ipt_MASQUERADE iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack ip_tables x_tables autofs4 nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc fuse loop qcserial usb_wwan usbserial btusb bluetooth snd_hda_codec_hdmi snd_hda_codec_conexant arc4 iwldvm mac80211 thinkpad_acpi nvram iTCO_wdt iTCO_vendor_support snd_seq_midi snd_seq_midi_event mxm_wmi snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_rawmidi snd_pcm snd_page_alloc coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel snd_seq snd_timer snd_seq_device snd aesni_intel ac pcspkr psmouse aes_x86_64 ablk_helper battery cryptd serio_raw lrw tpm_tis gf128mul tpm glue_helper tpm_bios evdev i915 iwlwifi wmi drm_kms_helper video intel_ips drm i2c_
 algo_bit soundcore cfg80211 ehci_pci i2c_i801 ehci_hcd lpc_ich i2c_core mfd_core rfkill usbcore usb_common acpi_cpufreq button processor ext4 crc16 jbd2 mbcache sg sd_mod sr_mod crc_t10dif cdrom crct10dif_common microcode ahci libahci libata scsi_mod thermal thermal_sys sdhci_pci sdhci mmc_core e1000e ptp pps_core
[ 1736.011281] CPU: 1 PID: 6800 Comm: kworker/u8:2 Tainted: G        W    3.12.0-rc6+ #3
[ 1736.011283] Hardware name: LENOVO 2912W1C/2912W1C, BIOS 6UET70WW (1.50 ) 10/11/2012
[ 1736.011298] Workqueue: phy0 ieee80211_iface_work [mac80211]
[ 1736.011301]  0000000000000000 0000000000000009 ffffffff81373aba 0000000000000000
[ 1736.011306]  ffffffff8103732b ffff8800b5930ece ffffffffa02663ca ffff8800373577b0
[ 1736.011310]  000000000000000f ffff8800b4818220 ffff8800af03dd70 ffff8800b4818220
[ 1736.011315] Call Trace:
[ 1736.011322]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[ 1736.011327]  [<ffffffff8103732b>] ? warn_slowpath_common+0x78/0x90
[ 1736.011342]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1736.011355]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1736.011368]  [<ffffffffa026653a>] ? cfg80211_reg_can_beacon+0x40/0x90 [cfg80211]
[ 1736.011382]  [<ffffffffa0523bc3>] ? __ieee80211_sta_join_ibss+0x15b/0x6e7 [mac80211]
[ 1736.011387]  [<ffffffff81371724>] ? printk+0x4f/0x54
[ 1736.011399]  [<ffffffffa0524217>] ? ieee80211_sta_create_ibss+0xc8/0xce [mac80211]
[ 1736.011412]  [<ffffffffa0524f9d>] ? ieee80211_ibss_work+0x250/0x3c0 [mac80211]
[ 1736.011417]  [<ffffffff8104b960>] ? process_one_work+0x191/0x294
[ 1736.011421]  [<ffffffff8104be12>] ? worker_thread+0x121/0x1e7
[ 1736.011424]  [<ffffffff8104bcf1>] ? rescuer_thread+0x269/0x269
[ 1736.011429]  [<ffffffff81050819>] ? kthread+0x81/0x89
[ 1736.011433]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1736.011438]  [<ffffffff8137c83c>] ? ret_from_fork+0x7c/0xb0
[ 1736.011442]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1736.011445] ---[ end trace 426d84b14a51a2b9 ]---
[ 1736.011447] wlan0: Failed to join IBSS, beacons forbidden
[ 1738.008341] wlan0: Trigger new scan to find an IBSS to join
[ 1738.029843] wlan0: Creating new IBSS network, BSSID d6:b3:47:e6:02:c5
[ 1738.029852] ------------[ cut here ]------------
[ 1738.029881] WARNING: CPU: 2 PID: 6800 at net/wireless/chan.c:373 cfg80211_chandef_usable+0x31/0x161 [cfg80211]()
[ 1738.029884] Modules linked in: ipt_MASQUERADE iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack ip_tables x_tables autofs4 nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc fuse loop qcserial usb_wwan usbserial btusb bluetooth snd_hda_codec_hdmi snd_hda_codec_conexant arc4 iwldvm mac80211 thinkpad_acpi nvram iTCO_wdt iTCO_vendor_support snd_seq_midi snd_seq_midi_event mxm_wmi snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_rawmidi snd_pcm snd_page_alloc coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel snd_seq snd_timer snd_seq_device snd aesni_intel ac pcspkr psmouse aes_x86_64 ablk_helper battery cryptd serio_raw lrw tpm_tis gf128mul tpm glue_helper tpm_bios evdev i915 iwlwifi wmi drm_kms_helper video intel_ips drm i2c_
 algo_bit soundcore cfg80211 ehci_pci i2c_i801 ehci_hcd lpc_ich i2c_core mfd_core rfkill usbcore usb_common acpi_cpufreq button processor ext4 crc16 jbd2 mbcache sg sd_mod sr_mod crc_t10dif cdrom crct10dif_common microcode ahci libahci libata scsi_mod thermal thermal_sys sdhci_pci sdhci mmc_core e1000e ptp pps_core
[ 1738.029987] CPU: 2 PID: 6800 Comm: kworker/u8:2 Tainted: G        W    3.12.0-rc6+ #3
[ 1738.029990] Hardware name: LENOVO 2912W1C/2912W1C, BIOS 6UET70WW (1.50 ) 10/11/2012
[ 1738.030005] Workqueue: phy0 ieee80211_iface_work [mac80211]
[ 1738.030008]  0000000000000000 0000000000000009 ffffffff81373aba 0000000000000000
[ 1738.030013]  ffffffff8103732b 0000000000000002 ffffffffa02663ca 0000000000000000
[ 1738.030017]  000000000000000f ffff8800b4818220 ffff8800af03dd70 ffff8800b4818220
[ 1738.030021] Call Trace:
[ 1738.030030]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[ 1738.030036]  [<ffffffff8103732b>] ? warn_slowpath_common+0x78/0x90
[ 1738.030050]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1738.030064]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1738.030077]  [<ffffffffa026653a>] ? cfg80211_reg_can_beacon+0x40/0x90 [cfg80211]
[ 1738.030090]  [<ffffffffa0523bc3>] ? __ieee80211_sta_join_ibss+0x15b/0x6e7 [mac80211]
[ 1738.030096]  [<ffffffff81371724>] ? printk+0x4f/0x54
[ 1738.030108]  [<ffffffffa0524217>] ? ieee80211_sta_create_ibss+0xc8/0xce [mac80211]
[ 1738.030121]  [<ffffffffa0524f9d>] ? ieee80211_ibss_work+0x250/0x3c0 [mac80211]
[ 1738.030126]  [<ffffffff8104b960>] ? process_one_work+0x191/0x294
[ 1738.030130]  [<ffffffff8104be12>] ? worker_thread+0x121/0x1e7
[ 1738.030134]  [<ffffffff8104bcf1>] ? rescuer_thread+0x269/0x269
[ 1738.030138]  [<ffffffff81050819>] ? kthread+0x81/0x89
[ 1738.030143]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1738.030148]  [<ffffffff8137c83c>] ? ret_from_fork+0x7c/0xb0
[ 1738.030152]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1738.030155] ---[ end trace 426d84b14a51a2ba ]---
[ 1738.030157] wlan0: Failed to join IBSS, beacons forbidden
[ 1739.997578] wlan0: Creating new IBSS network, BSSID fa:3b:78:1a:1c:8b
[ 1739.997587] ------------[ cut here ]------------
[ 1739.997613] WARNING: CPU: 1 PID: 6800 at net/wireless/chan.c:373 cfg80211_chandef_usable+0x31/0x161 [cfg80211]()
[ 1739.997615] Modules linked in: ipt_MASQUERADE iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack ip_tables x_tables autofs4 nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc fuse loop qcserial usb_wwan usbserial btusb bluetooth snd_hda_codec_hdmi snd_hda_codec_conexant arc4 iwldvm mac80211 thinkpad_acpi nvram iTCO_wdt iTCO_vendor_support snd_seq_midi snd_seq_midi_event mxm_wmi snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_rawmidi snd_pcm snd_page_alloc coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel snd_seq snd_timer snd_seq_device snd aesni_intel ac pcspkr psmouse aes_x86_64 ablk_helper battery cryptd serio_raw lrw tpm_tis gf128mul tpm glue_helper tpm_bios evdev i915 iwlwifi wmi drm_kms_helper video intel_ips drm i2c_
 algo_bit soundcore cfg80211 ehci_pci i2c_i801 ehci_hcd lpc_ich i2c_core mfd_core rfkill usbcore usb_common acpi_cpufreq button processor ext4 crc16 jbd2 mbcache sg sd_mod sr_mod crc_t10dif cdrom crct10dif_common microcode ahci libahci libata scsi_mod thermal thermal_sys sdhci_pci sdhci mmc_core e1000e ptp pps_core
[ 1739.997707] CPU: 1 PID: 6800 Comm: kworker/u8:2 Tainted: G        W    3.12.0-rc6+ #3
[ 1739.997709] Hardware name: LENOVO 2912W1C/2912W1C, BIOS 6UET70WW (1.50 ) 10/11/2012
[ 1739.997724] Workqueue: phy0 ieee80211_iface_work [mac80211]
[ 1739.997726]  0000000000000000 0000000000000009 ffffffff81373aba 0000000000000000
[ 1739.997731]  ffffffff8103732b 0000000000000006 ffffffffa02663ca 0000000000000000
[ 1739.997735]  000000000000000f ffff8800b4818220 ffff8800af03dd70 ffff8800b4818220
[ 1739.997740] Call Trace:
[ 1739.997748]  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
[ 1739.997753]  [<ffffffff8103732b>] ? warn_slowpath_common+0x78/0x90
[ 1739.997767]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1739.997781]  [<ffffffffa02663ca>] ? cfg80211_chandef_usable+0x31/0x161 [cfg80211]
[ 1739.997794]  [<ffffffffa026653a>] ? cfg80211_reg_can_beacon+0x40/0x90 [cfg80211]
[ 1739.997807]  [<ffffffffa0523bc3>] ? __ieee80211_sta_join_ibss+0x15b/0x6e7 [mac80211]
[ 1739.997812]  [<ffffffff81371724>] ? printk+0x4f/0x54
[ 1739.997825]  [<ffffffffa0524217>] ? ieee80211_sta_create_ibss+0xc8/0xce [mac80211]
[ 1739.997838]  [<ffffffffa0524f9d>] ? ieee80211_ibss_work+0x250/0x3c0 [mac80211]
[ 1739.997842]  [<ffffffff8104b960>] ? process_one_work+0x191/0x294
[ 1739.997846]  [<ffffffff8104be12>] ? worker_thread+0x121/0x1e7
[ 1739.997850]  [<ffffffff8104bcf1>] ? rescuer_thread+0x269/0x269
[ 1739.997854]  [<ffffffff81050819>] ? kthread+0x81/0x89
[ 1739.997859]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1739.997864]  [<ffffffff8137c83c>] ? ret_from_fork+0x7c/0xb0
[ 1739.997868]  [<ffffffff81050798>] ? __kthread_parkme+0x5d/0x5d
[ 1739.997871] ---[ end trace 426d84b14a51a2bb ]---
[ 1739.997874] wlan0: Failed to join IBSS, beacons forbidden
[ 1742.010809] wlan0: Trigger new scan to find an IBSS to join
[ 1742.032428] wlan0: Selected IBSS BSSID 02:54:99:bb:01:aa based on configured SSID
[ 1742.037372] iwlwifi 0000:03:00.0: Unable to find TIM Element in beacon
[ 1742.038596] iwlwifi 0000:03:00.0: Unable to find TIM Element in beacon
[ 1742.038837] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready

Cheers,
        Thomas
