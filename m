From: "J.H." <warthog9@kernel.org>
Subject: Simultaneous error on two different machines
Date: Wed, 26 Jan 2011 16:36:58 -0800
Message-ID: <4D40BE2A.2010903@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36618 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647Ab1A0AhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 19:37:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Afternoon,

Happened to trip over this yesterday on two machines (one an HP DL380 G6
and one an HP DL 380 G7).  Error was within minutes of each other,
identical on the two boxes.  Driver seemed to reset (as indicated
below), however loads on the two boxes almost immediately skyrocketed,
eventually leading to a more serious deadlock panic on one of the boxes,
and me just rebooting the other.

The chipsets involved seem to be:

Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit
Ethernet (rev 20)

Kernel is from Fedora 13, 2.6.34.7-61.korg.fc13.x86_64.  The only
additional patches applied involve fixing an XFS bug.

Here follows what I was able to snag from the system:

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0xf5/0x197()
Hardware name: ProLiant DL380 G6
NETDEV WATCHDOG: eth0 (bnx2): transmit queue 2 timed out
Modules linked in: ipmi_devintf coretemp ipv6 xt_multiport
iptable_mangle xfs exportfs uinput hpwdt ipmi_si ipmi_msghandler bnx2
iTCO_wdt iTCO_vendor_support serio_raw microcode power_meter raid0 cciss
hpsa radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded:
speedstep_lib]
Pid: 0, comm: swapper Tainted: G   M       2.6.34.7-61.korg.fc13.x86_64 #1
Call Trace:
 <IRQ>  [<ffffffff8104d14f>] warn_slowpath_common+0x7c/0x94
 [<ffffffff8104d1be>] warn_slowpath_fmt+0x41/0x43
 [<ffffffff813b530f>] ? netif_tx_lock+0x44/0x6d
 [<ffffffff813b542d>] dev_watchdog+0xf5/0x197
 [<ffffffff81010261>] ? sched_clock+0x9/0xd
 [<ffffffff8106b2f7>] ? sched_clock_cpu+0x44/0xce
 [<ffffffff810594d6>] run_timer_softirq+0x1bf/0x263
 [<ffffffff8106e3f7>] ? ktime_get+0x65/0xbe
 [<ffffffff81053285>] __do_softirq+0xe5/0x1a6
 [<ffffffff810726d0>] ? tick_program_event+0x2a/0x2c
 [<ffffffff8100ab5c>] call_softirq+0x1c/0x30
 [<ffffffff8100c342>] do_softirq+0x46/0x83
 [<ffffffff810530f6>] irq_exit+0x3b/0x7d
 [<ffffffff8144dc30>] smp_apic_timer_interrupt+0x8d/0x9b
 [<ffffffff8100a613>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff8127d4c7>] ? acpi_idle_enter_bm+0x288/0x2bc
 [<ffffffff8127d4c0>] ? acpi_idle_enter_bm+0x281/0x2bc
 [<ffffffff8137596c>] ? menu_select+0x141/0x1f8
 [<ffffffff81374b74>] cpuidle_idle_call+0x99/0xf1
 [<ffffffff81008c22>] cpu_idle+0xaa/0xe4
 [<ffffffff81440b89>] start_secondary+0x253/0x294
---[ end trace d6fc5aa3e2b641f7 ]---
bnx2 0000:02:00.0: eth0: DEBUG: intr_sem[0]
bnx2 0000:02:00.0: eth0: DEBUG: EMAC_TX_STATUS[00000008]
RPM_MGMT_PKT_CTRL[40000088]
bnx2 0000:02:00.0: eth0: DEBUG: MCP_STATE_P0[0003610e]
MCP_STATE_P1[0003600e]
bnx2 0000:02:00.0: eth0: DEBUG: HC_STATS_INTERRUPT_STATUS[01fb0004]
bnx2 0000:02:00.0: eth0: DEBUG: PBA[00000000]
bnx2 0000:02:00.0: eth0: NIC Copper Link is Down
bnx2 0000:02:00.0: eth0: NIC Copper Link is Up, 1000 Mbps full duplex

- John 'Warthog9' Hawley
