From: Dave Jones <davej@redhat.com>
Subject: failure to find rate WARN_ON on iwlagn
Date: Wed, 6 Jul 2011 11:11:28 -0400
Message-ID: <20110706151128.GB1425@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: ilw@linux.intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8844 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752572Ab1GFPLb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 11:11:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just hit this trace 3 times on this hardware..
04:00.0 Network controller: Intel Corporation Ultimate N WiFi Link 5300

	Dave

wlan0: authenticate with b8:c7:5d:0c:39:88 (try 1)
wlan0: authenticate with b8:c7:5d:0c:39:88 (try 2)
wlan0: authenticate with b8:c7:5d:0c:39:88 (try 3)
wlan0: authentication with b8:c7:5d:0c:39:88 timed out
------------[ cut here ]------------
WARNING: at include/net/mac80211.h:3081 rate_control_send_low+0x8b/0x10f [mac80211]()
Hardware name: Adamo 13   
Modules linked in: sctp libcrc32c ip_queue can_raw cmtp kernelcapi rfcomm can_bcm hidp caif_socket caif af_802154 phonet af_rxrpc can pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose ax25 x25 atm appletalk ipx p8022 psnap llc p8023 tcp_lp nfs fscache fuse nfsd lockd nfs_acl auth_rpcgss sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables btusb bluetooth arc4 dell_wmi sparse_keymap snd_usb_audio snd_usbmidi_lib snd_rawmidi snd_hda_codec_hdmi snd_hda_codec_idt cdc_ether usbnet cdc_wdm mii snd_hda_intel snd_hda_codec snd_hwdep cdc_acm uvcvideo dell_laptop snd_seq microcode videodev v4l2_compat_ioctl32 dcdbas snd_seq_device snd_pcm iwlagn mac80211 iTCO_wdt tg3 cfg80211 pcspkr joydev i2c_i801 iTCO_vendor_
 support rfkill snd_timer snd soundcore snd_page_alloc wmi virtio_net kvm_intel kvm ipv6 xts gf128mul dm_crypt i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
Pid: 0, comm: swapper Not tainted 3.0.0-rc5+ #89
Call Trace:
 <IRQ>  [<ffffffff8105acfc>] warn_slowpath_common+0x83/0x9b
 [<ffffffff8105ad2e>] warn_slowpath_null+0x1a/0x1c
 [<ffffffffa0252b17>] rate_control_send_low+0x8b/0x10f [mac80211]
 [<ffffffffa0291c59>] rs_get_rate+0x138/0x215 [iwlagn]
 [<ffffffffa0252fcf>] rate_control_get_rate+0x86/0x14c [mac80211]
 [<ffffffff814cf60e>] ? _raw_spin_unlock_irqrestore+0x6c/0x7a
 [<ffffffffa025bde1>] invoke_tx_handlers+0x8f3/0xf47 [mac80211]
 [<ffffffffa025a4f0>] ? compare_ether_addr+0x2c/0x2c [mac80211]
 [<ffffffff814c818e>] ? __slab_alloc+0x399/0x3b4
 [<ffffffffa025c4b4>] ieee80211_tx+0x7f/0xaf [mac80211]
 [<ffffffffa025c66a>] ieee80211_xmit+0x186/0x19a [mac80211]
 [<ffffffff81060d3f>] ? __local_bh_disable+0x8c/0xbe
 [<ffffffffa025d5dc>] ieee80211_tx_skb+0x56/0x5e [mac80211]
 [<ffffffffa02493c3>] ieee80211_send_bar+0xda/0xe9 [mac80211]
 [<ffffffffa0243928>] ieee80211_tx_status+0x25c/0x808 [mac80211]
 [<ffffffff814cf600>] ? _raw_spin_unlock_irqrestore+0x5e/0x7a
 [<ffffffffa0242d12>] ieee80211_tasklet_handler+0x5b/0xa8 [mac80211]
 [<ffffffff81061311>] tasklet_action+0x93/0xf3
 [<ffffffff810614ba>] __do_softirq+0x10f/0x257
 [<ffffffff814d6bdc>] call_softirq+0x1c/0x30
 [<ffffffff8100bcaa>] do_softirq+0x4b/0xa1
 [<ffffffff8106189d>] irq_exit+0x5d/0xb5
 [<ffffffff814d747d>] do_IRQ+0x8d/0xa4
 [<ffffffff814cfc13>] common_interrupt+0x13/0x13
 <EOI>  [<ffffffff814d29f7>] ? notifier_call_chain+0xbb/0xbb
 [<ffffffff812e11c3>] ? arch_local_irq_enable+0x8/0xd
 [<ffffffff8108e2a8>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff812e1d80>] acpi_idle_enter_c1+0xa0/0xbe
 [<ffffffff813e0acb>] cpuidle_idle_call+0x10c/0x1eb
 [<ffffffff81009323>] cpu_idle+0xe3/0x143
 [<ffffffff81d3dbc2>] ? start_kernel+0x401/0x40c
 [<ffffffff814abc71>] rest_init+0xd5/0xdc
 [<ffffffff814abb9c>] ? csum_partial_copy_generic+0x16c/0x16c
 [<ffffffff81d3dbc2>] start_kernel+0x401/0x40c
 [<ffffffff81d3d2c4>] x86_64_start_reservations+0xaf/0xb3
 [<ffffffff81d3d140>] ? early_idt_handlers+0x140/0x140
 [<ffffffff81d3d3ca>] x86_64_start_kernel+0x102/0x111
---[ end trace ab18f52dc63f6394 ]---

