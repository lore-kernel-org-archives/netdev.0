From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Mon, 22 May 2017 12:36:52 +0200
Message-ID: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.eikelenboom.it ([91.121.65.215]:47704 "EHLO
        server.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757468AbdEVKta (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 06:49:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I encountered this splat with 4.12-RC2.
--

Sander

[  119.021594] BUG: scheduling while atomic: irq/47-iwlwifi/517/0x00000200
[  119.021604] Modules linked in: xt_tcpudp ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_raw ip6table_security ip6table_mangle iptable_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_security iptable_mangle ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables x_tables rfcomm bnep binfmt_misc arc4 iTCO_wdt iTCO_vendor_support uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_core videodev intel_rapl cdc_mbim iwlmvm x86_pkg_temp_thermal intel_powerclamp mac80211 media cdc_wdm btusb coretemp cdc_ncm kvm_intel usbnet mii cdc_acm iwlwifi kvm btintel joydev pcspkr serio_raw cfg802
 11 snd_hda_codec_hdmi
[  119.021701]  bluetooth lpc_ich snd_hda_codec_realtek snd_hda_codec_generic shpchp sg ecdh_generic snd_hda_intel thinkpad_acpi snd_hda_codec snd_hwdep snd_hda_core snd_pcm snd_timer nvram snd soundcore evdev tpm_tis tpm_tis_core tpm algif_skcipher af_alg crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel rtsx_pci_sdmmc mmc_core aesni_intel aes_x86_64 crypto_simd cryptd glue_helper psmouse i2c_i801 sd_mod ehci_pci ehci_hcd e1000e rtsx_pci mfd_core ptp xhci_pci pps_core xhci_hcd
[  119.021759] CPU: 1 PID: 517 Comm: irq/47-iwlwifi Not tainted 4.12.0-rc2-t440s-20170522+ #1
[  119.021763] Hardware name: LENOVO 20AQS03H00/20AQS03H00, BIOS GJET91WW (2.41 ) 09/21/2016
[  119.021766] Call Trace:
[  119.021778]  ? dump_stack+0x5c/0x84
[  119.021784]  ? __schedule_bug+0x4c/0x70
[  119.021792]  ? __schedule+0x496/0x5c0
[  119.021798]  ? schedule+0x2d/0x80
[  119.021804]  ? schedule_preempt_disabled+0x5/0x10
[  119.021810]  ? __mutex_lock.isra.0+0x18e/0x4c0
[  119.021817]  ? __wake_up+0x2f/0x50
[  119.021833]  ? cfg80211_sched_scan_results+0x19/0x60 [cfg80211]
[  119.021844]  ? cfg80211_sched_scan_results+0x19/0x60 [cfg80211]
[  119.021859]  ? iwl_mvm_rx_lmac_scan_iter_complete_notif+0x17/0x30 [iwlmvm]
[  119.021869]  ? iwl_pcie_rx_handle+0x2a9/0x7e0 [iwlwifi]
[  119.021878]  ? iwl_pcie_irq_handler+0x17c/0x730 [iwlwifi]
[  119.021884]  ? irq_forced_thread_fn+0x60/0x60
[  119.021887]  ? irq_thread_fn+0x16/0x40
[  119.021892]  ? irq_thread+0x109/0x180
[  119.021896]  ? wake_threads_waitq+0x30/0x30
[  119.021901]  ? kthread+0xf2/0x130
[  119.021905]  ? irq_thread_dtor+0x90/0x90
[  119.021910]  ? kthread_create_on_node+0x40/0x40
[  119.021915]  ? ret_from_fork+0x26/0x40
