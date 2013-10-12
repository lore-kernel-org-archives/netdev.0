From: Andre Tomt <andre@tomt.net>
Subject: Re: 3.12-git Intel e1000e hardware unit hang / tx queue timeouts
Date: Sat, 12 Oct 2013 17:30:06 +0200
Message-ID: <52596AFE.8050800@tomt.net>
References: <52594DBD.3070108@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.ugh.no ([178.79.162.34]:45654 "EHLO mail1.ugh.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100Ab3JLPaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Oct 2013 11:30:10 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail1.ugh.no (Postfix) with ESMTP id 25AE226C57A
	for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 17:30:09 +0200 (CEST)
Received: from mail1.ugh.no ([127.0.0.1])
	by localhost (catastrophix.ugh.no [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vxLLi1W28kXH for <netdev@vger.kernel.org>;
	Sat, 12 Oct 2013 17:30:07 +0200 (CEST)
Received: from [IPv6:2a02:fe0:cf17:31:a236:9fff:fe07:d8ab] (unknown [IPv6:2a02:fe0:cf17:31:a236:9fff:fe07:d8ab])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: andre@tomt.net)
	by mail.ugh.no (Postfix) with ESMTPSA id 7BAA426C58D
	for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 17:30:07 +0200 (CEST)
In-Reply-To: <52594DBD.3070108@tomt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12. okt. 2013 15:25, Andre Tomt wrote:
> I'm going to boot 3.10.16 on it now, and see how it fares.

3.10.16 is just as flaky.
Turning the offloads back off for now, will try to dig a little deeper 
later.

3.10 log:
> [ 2990.799280] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
> [ 2990.799280]   TDH                  <f8>
> [ 2990.799280]   TDT                  <1a>
> [ 2990.799280]   next_to_use          <1a>
> [ 2990.799280]   next_to_clean        <f6>
> [ 2990.799280] buffer_info[next_to_clean]:
> [ 2990.799280]   time_stamp           <1000a3f4a>
> [ 2990.799280]   next_to_watch        <f8>
> [ 2990.799280]   jiffies              <1000a41cd>
> [ 2990.799280]   next_to_watch.status <0>
> [ 2990.799280] MAC Status             <80083>
> [ 2990.799280] PHY Status             <796d>
> [ 2990.799280] PHY 1000BASE-T Status  <7800>
> [ 2990.799280] PHY Extended Status    <3000>
> [ 2990.799280] PCI Status             <10>
> [ 2992.800488] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
> [ 2992.800488]   TDH                  <f8>
> [ 2992.800488]   TDT                  <1a>
> [ 2992.800488]   next_to_use          <1a>
> [ 2992.800488]   next_to_clean        <f6>
> [ 2992.800488] buffer_info[next_to_clean]:
> [ 2992.800488]   time_stamp           <1000a3f4a>
> [ 2992.800488]   next_to_watch        <f8>
> [ 2992.800488]   jiffies              <1000a43c1>
> [ 2992.800488]   next_to_watch.status <0>
> [ 2992.800488] MAC Status             <80083>
> [ 2992.800488] PHY Status             <796d>
> [ 2992.800488] PHY 1000BASE-T Status  <7800>
> [ 2992.800488] PHY Extended Status    <3000>
> [ 2992.800488] PCI Status             <10>
> [ 2994.801816] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
> [ 2994.801816]   TDH                  <f8>
> [ 2994.801816]   TDT                  <1a>
> [ 2994.801816]   next_to_use          <1a>
> [ 2994.801816]   next_to_clean        <f6>
> [ 2994.801816] buffer_info[next_to_clean]:
> [ 2994.801816]   time_stamp           <1000a3f4a>
> [ 2994.801816]   next_to_watch        <f8>
> [ 2994.801816]   jiffies              <1000a45b5>
> [ 2994.801816]   next_to_watch.status <0>
> [ 2994.801816] MAC Status             <80083>
> [ 2994.801816] PHY Status             <796d>
> [ 2994.801816] PHY 1000BASE-T Status  <7800>
> [ 2994.801816] PHY Extended Status    <3000>
> [ 2994.801816] PCI Status             <10>
> [ 2995.805673] ------------[ cut here ]------------
> [ 2995.805684] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x185/0x1eb()
> [ 2995.805695] NETDEV WATCHDOG: em2 (e1000e): transmit queue 0 timed out
> [ 2995.805697] Modules linked in: vhost_net macvtap macvlan tun xt_pkttype xt_CT iptable_raw ipt_MASQUERADE xt_nat iptable_nat nf_nat_ipv4 nf_nat ip6t_frag ip6t_ah ip6t_REJECT ebtable_nat ip6table_filter ebtables ip6_tables xt_LOG xt_limit ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_tcpudp xt_conntrack nf_conntrack xt_multiport iptable_filter ip_tables x_tables iTCO_wdt iTCO_vendor_support act_mirred cls_u32 sch_ingress sch_fq_codel sch_hfsc fbcon bitblit softcursor font tileblit bridge arc4 8021q garp stp mrp llc dm_multipath scsi_dh ath9k ath9k_common ath9k_hw ath coretemp mac80211 crc32_pclmul crc32c_intel ghash_clmulni_intel cryptd lpc_ich cfg80211 mfd_core rfkill firmware_class i915 intel_agp intel_gtt drm_kms_helper drm i2c_algo_bit mei_me i2c_core mei tpm_tis evdev tpm tpm_bios
  ehci_pci ehci_hcd video kvm_intel kvm ifb dummy w83627ehf hwmon_vid hwmon ext4 crc16 jbd2 mbcache dm_mod sd_mod ahci e1000e libahci xhci_hcd ptp pps_core usbcore usb_common
> [ 2995.805772] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.0-1-server #1
> [ 2995.805774] Hardware name:                  /DQ77KB, BIOS KBQ7710H.86A.0052.2013.0708.1336 07/08/2013
> [ 2995.805777]  00000000000114a8 ffff88021e203da0 ffffffff813394c7 ffff88021e203dd8
> [ 2995.805780]  ffffffff8102d71c ffff88021e203de8 ffff88020fd0c000 ffff880212b8cc00
> [ 2995.805783]  0000000000000001 0000000000000000 ffff88021e203e38 ffffffff8102d77b
> [ 2995.805787] Call Trace:
> [ 2995.805788]  <IRQ>  [<ffffffff813394c7>] dump_stack+0x19/0x1b
> [ 2995.805799]  [<ffffffff8102d71c>] warn_slowpath_common+0x60/0x78
> [ 2995.805802]  [<ffffffff8102d77b>] warn_slowpath_fmt+0x47/0x49
> [ 2995.805808]  [<ffffffff812956c6>] dev_watchdog+0x185/0x1eb
> [ 2995.805812]  [<ffffffff81295541>] ? dev_graft_qdisc+0x66/0x66
> [ 2995.805815]  [<ffffffff81295541>] ? dev_graft_qdisc+0x66/0x66
> [ 2995.805820]  [<ffffffff810384c3>] call_timer_fn.isra.26+0x23/0x7b
> [ 2995.805823]  [<ffffffff810386c6>] run_timer_softirq+0x1ab/0x1d3
> [ 2995.805826]  [<ffffffff8103362e>] __do_softirq+0xbf/0x173
> [ 2995.805831]  [<ffffffff8133f07c>] call_softirq+0x1c/0x30
> [ 2995.805836]  [<ffffffff810035b7>] do_softirq+0x2e/0x69
> [ 2995.805838]  [<ffffffff810337ac>] irq_exit+0x3e/0x4c
> [ 2995.805842]  [<ffffffff8101d092>] smp_apic_timer_interrupt+0x86/0x94
> [ 2995.805846]  [<ffffffff8133ea0a>] apic_timer_interrupt+0x6a/0x70
> [ 2995.805847]  <EOI>  [<ffffffff81253412>] ? cpuidle_enter_state+0x4d/0x9e
> [ 2995.805853]  [<ffffffff8125340b>] ? cpuidle_enter_state+0x46/0x9e
> [ 2995.805856]  [<ffffffff81253535>] cpuidle_idle_call+0xd2/0x121
> [ 2995.805860]  [<ffffffff81008dfd>] arch_cpu_idle+0x9/0x18
> [ 2995.805864]  [<ffffffff8105e497>] cpu_startup_entry+0xfc/0x148
> [ 2995.805868]  [<ffffffff813252de>] rest_init+0x72/0x74
> [ 2995.805873]  [<ffffffff81686cd0>] start_kernel+0x3d7/0x3e2
> [ 2995.805877]  [<ffffffff81686748>] ? do_early_param+0x93/0x93
> [ 2995.805881]  [<ffffffff8168647f>] x86_64_start_reservations+0x2a/0x2c
> [ 2995.805885]  [<ffffffff81686548>] x86_64_start_kernel+0xc7/0xca
> [ 2995.805887] ---[ end trace fd899d2b4fca47a0 ]---
> [ 2995.805901] e1000e 0000:00:19.0 em2: Reset adapter unexpectedly
> [ 2999.697213] e1000e: em2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
> [ 3949.321404] UDP: bad checksum. From 87.114.227.207:53185 to 84.209.201.2:51413 ulen 40
> [ 6117.966435] UDP: bad checksum. From 109.61.95.12:62354 to 84.209.201.2:51413 ulen 114
> [ 6520.077066] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
> [ 6520.077066]   TDH                  <26>
> [ 6520.077066]   TDT                  <33>
> [ 6520.077066]   next_to_use          <33>
> [ 6520.077066]   next_to_clean        <24>
> [ 6520.077066] buffer_info[next_to_clean]:
> [ 6520.077066]   time_stamp           <10017b369>
> [ 6520.077066]   next_to_watch        <26>
> [ 6520.077066]   jiffies              <10017b623>
> [ 6520.077066]   next_to_watch.status <0>
> [ 6520.077066] MAC Status             <80083>
> [ 6520.077066] PHY Status             <796d>
> [ 6520.077066] PHY 1000BASE-T Status  <7800>
> [ 6520.077066] PHY Extended Status    <3000>
> [ 6520.077066] PCI Status             <10>
> [ 6522.078332] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
> [ 6522.078332]   TDH                  <26>
> [ 6522.078332]   TDT                  <33>
> [ 6522.078332]   next_to_use          <33>
> [ 6522.078332]   next_to_clean        <24>
> [ 6522.078332] buffer_info[next_to_clean]:
> [ 6522.078332]   time_stamp           <10017b369>
> [ 6522.078332]   next_to_watch        <26>
> [ 6522.078332]   jiffies              <10017b817>
> [ 6522.078332]   next_to_watch.status <0>
> [ 6522.078332] MAC Status             <80083>
> [ 6522.078332] PHY Status             <796d>
> [ 6522.078332] PHY 1000BASE-T Status  <7800>
> [ 6522.078332] PHY Extended Status    <3000>
> [ 6522.078332] PCI Status             <10>
> [ 6524.079633] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
> [ 6524.079633]   TDH                  <26>
> [ 6524.079633]   TDT                  <33>
> [ 6524.079633]   next_to_use          <33>
> [ 6524.079633]   next_to_clean        <24>
> [ 6524.079633] buffer_info[next_to_clean]:
> [ 6524.079633]   time_stamp           <10017b369>
> [ 6524.079633]   next_to_watch        <26>
> [ 6524.079633]   jiffies              <10017ba0b>
> [ 6524.079633]   next_to_watch.status <0>
> [ 6524.079633] MAC Status             <80083>
> [ 6524.079633] PHY Status             <796d>
> [ 6524.079633] PHY 1000BASE-T Status  <7800>
> [ 6524.079633] PHY Extended Status    <3000>
> [ 6524.079633] PCI Status             <10>
> [ 6526.080929] e1000e 0000:00:19.0 em2: Detected Hardware Unit Hang:
> [ 6526.080929]   TDH                  <26>
> [ 6526.080929]   TDT                  <33>
> [ 6526.080929]   next_to_use          <33>
> [ 6526.080929]   next_to_clean        <24>
> [ 6526.080929] buffer_info[next_to_clean]:
> [ 6526.080929]   time_stamp           <10017b369>
> [ 6526.080929]   next_to_watch        <26>
> [ 6526.080929]   jiffies              <10017bbff>
> [ 6526.080929]   next_to_watch.status <0>
> [ 6526.080929] MAC Status             <80083>
> [ 6526.080929] PHY Status             <796d>
> [ 6526.080929] PHY 1000BASE-T Status  <7800>
> [ 6526.080929] PHY Extended Status    <3000>
> [ 6526.080929] PCI Status             <10>
> [ 6527.092694] e1000e 0000:00:19.0 em2: Reset adapter unexpectedly
> [ 6530.984252] e1000e: em2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
