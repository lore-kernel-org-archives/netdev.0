From: Roland Stigge <stigge@antcom.de>
Subject: r8169 delay / segfault
Date: Fri, 12 Oct 2012 21:35:37 +0200
Message-ID: <50787109.7080605@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:45979 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123Ab2JLTfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 15:35:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

on a Samsung laptop (x86_64, kernel 3.6.0), I get the following messages in the kernel
log after a suspend/resume cycle (doesn't happen after every suspend/resume but sometimes):

Oct 12 21:02:27 darwin kernel: [ 4289.829755] r8169 0000:02:00.0: wake-up capability disabled by ACPI
Oct 12 21:02:27 darwin kernel: [ 4289.830351] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.831077] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.831671] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.832214] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.832757] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.833303] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.834885] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.835429] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.835972] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.836518] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.857820] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.858371] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
Oct 12 21:02:27 darwin kernel: [ 4289.858920] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).

[...]

Oct 12 21:04:38 darwin kernel: [ 4422.635491] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:38 darwin kernel: [ 4422.635499] r8169 0000:02:00.0: eth0: link up
Oct 12 21:04:56 darwin kernel: [ 4441.319712] ------------[ cut here ]------------
Oct 12 21:04:56 darwin kernel: [ 4441.319733] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xe3/0x153()
Oct 12 21:04:56 darwin kernel: [ 4441.319737] Hardware name: 900X3C/900X4C/900X4D
Oct 12 21:04:56 darwin kernel: [ 4441.319741] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Oct 12 21:04:56 darwin kernel: [ 4441.319744] Modules linked in: nf_conntrack_ipv6 nf_defrag_ipv6 xt_LOG xt_limit xt_tcpudp nf_conntrack_ipv4 nf_defrag_ipv4 x
t_state nf_conntrack_ftp xt_conntrack nf_conntrack ip6table_filter ip6_tables iptable_filter ip_tables ebtable_nat ebtables x_tables parport_pc ppdev lp parpo
rt bnep rfcomm binfmt_misc uinput nfsd auth_rpcgss nfs_acl nfs lockd fscache sunrpc loop fuse snd_hda_codec_hdmi snd_hda_codec_realtek joydev arc4 coretemp kv
m_intel kvm btusb iwldvm bluetooth crc32c_intel mac80211 ghash_clmulni_intel iTCO_wdt iTCO_vendor_support aesni_intel aes_x86_64 snd_hda_intel snd_hda_codec s
nd_hwdep snd_pcm aes_generic ablk_helper snd_page_alloc cryptd snd_seq snd_timer snd_seq_device samsung_laptop evdev snd iwlwifi i915 microcode drm_kms_helper
 drm soundcore psmouse pcspkr cfg80211 i2c_i801 lpc_ich i2c_algo_bit serio_raw mfd_core rfkill i2c_core battery acpi_cpufreq mperf wmi video ac button process
or ext4 crc16 jbd2 mbcache dm_mod sg sd_mod crc_t10dif ehci_hcd xhci_hcd fan th
Oct 12 21:04:56 darwin kernel: ermal ahci thermal_sys libahci usbcore r8169 mii usb_common libata scsi_mod
Oct 12 21:04:56 darwin kernel: [ 4441.319903] Pid: 0, comm: swapper/1 Not tainted 3.6.0 #1
Oct 12 21:04:56 darwin kernel: [ 4441.319906] Call Trace:
Oct 12 21:04:56 darwin kernel: [ 4441.319910]  <IRQ>  [<ffffffff8103c914>] ? warn_slowpath_common+0x76/0x8a
Oct 12 21:04:56 darwin kernel: [ 4441.319932]  [<ffffffff8103c9c0>] ? warn_slowpath_fmt+0x45/0x4a
Oct 12 21:04:56 darwin kernel: [ 4441.319941]  [<ffffffff812b9b62>] ? netif_tx_lock+0x67/0x7a
Oct 12 21:04:56 darwin kernel: [ 4441.319954]  [<ffffffff812b9c58>] ? dev_watchdog+0xe3/0x153
Oct 12 21:04:56 darwin kernel: [ 4441.319963]  [<ffffffff810492e1>] ? run_timer_softirq+0x19f/0x2b0
Oct 12 21:04:56 darwin kernel: [ 4441.319974]  [<ffffffff81068208>] ? trigger_load_balance+0x50/0x1df
Oct 12 21:04:56 darwin kernel: [ 4441.319980]  [<ffffffff812b9b75>] ? netif_tx_lock+0x7a/0x7a
Oct 12 21:04:56 darwin kernel: [ 4441.319989]  [<ffffffff811b8320>] ? timerqueue_add+0x80/0xa0
Oct 12 21:04:56 darwin kernel: [ 4441.319998]  [<ffffffff8104332f>] ? __do_softirq+0xac/0x1d1
Oct 12 21:04:56 darwin kernel: [ 4441.320007]  [<ffffffff81073706>] ? ktime_get+0x62/0x6a
Oct 12 21:04:56 darwin kernel: [ 4441.320015]  [<ffffffff81078109>] ? clockevents_program_event+0x9a/0xb6
Oct 12 21:04:56 darwin kernel: [ 4441.320025]  [<ffffffff81367ebc>] ? call_softirq+0x1c/0x30
Oct 12 21:04:56 darwin kernel: [ 4441.320036]  [<ffffffff8100f8fe>] ? do_softirq+0x3a/0x78
Oct 12 21:04:56 darwin kernel: [ 4441.320043]  [<ffffffff81043611>] ? irq_exit+0x3a/0x91
Oct 12 21:04:56 darwin kernel: [ 4441.320052]  [<ffffffff8102845c>] ? smp_apic_timer_interrupt+0x74/0x82
Oct 12 21:04:56 darwin kernel: [ 4441.320060]  [<ffffffff813677ca>] ? apic_timer_interrupt+0x6a/0x70
Oct 12 21:04:56 darwin kernel: [ 4441.320062]  <EOI>  [<ffffffff81078109>] ? clockevents_program_event+0x9a/0xb6
Oct 12 21:04:56 darwin kernel: [ 4441.320077]  [<ffffffff811f8174>] ? intel_idle+0xdf/0x10a
Oct 12 21:04:56 darwin kernel: [ 4441.320084]  [<ffffffff811f814f>] ? intel_idle+0xba/0x10a
Oct 12 21:04:56 darwin kernel: [ 4441.320094]  [<ffffffff812810b3>] ? cpuidle_enter_state+0xa/0x31
Oct 12 21:04:56 darwin kernel: [ 4441.320100]  [<ffffffff812811a7>] ? cpuidle_idle_call+0xcd/0x184
Oct 12 21:04:56 darwin kernel: [ 4441.320107]  [<ffffffff81014f30>] ? cpu_idle+0x9c/0xe6
Oct 12 21:04:56 darwin kernel: [ 4441.320117]  [<ffffffff81353e4f>] ? start_secondary+0x1d2/0x1d8
Oct 12 21:04:56 darwin kernel: [ 4441.320122] ---[ end trace 2ae2e4a392ef84b6 ]---
Oct 12 21:04:56 darwin kernel: [ 4441.330385] r8169 0000:02:00.0: eth0: rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.331592] r8169 0000:02:00.0: eth0: rtl_csiar_cond == 1 (loop: 100, delay: 10).
Oct 12 21:04:56 darwin kernel: [ 4441.332727] r8169 0000:02:00.0: eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
Oct 12 21:04:56 darwin kernel: [ 4441.333866] r8169 0000:02:00.0: eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
Oct 12 21:04:56 darwin kernel: [ 4441.343912] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.353943] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.363973] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.374003] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.384034] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.394065] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.404196] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.414334] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.424383] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.434412] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.444546] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.454683] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
Oct 12 21:04:56 darwin kernel: [ 4441.454689] r8169 0000:02:00.0: eth0: link up

I copied a bigger part of the kernel log at http://antcom.de/kernel/dmesg.

Please tell me how I can help debugging or what else information you need.

Thanks in advance,

Roland
