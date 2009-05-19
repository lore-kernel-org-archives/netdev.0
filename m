From: Ben Greear <greearb@candelatech.com>
Subject: ixgbe issues in 2.6.29.3
Date: Tue, 19 May 2009 08:51:37 -0700
Message-ID: <4A12D589.7040002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54037 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbZESPvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 11:51:35 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n4JFpaPm014870
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 19 May 2009 08:51:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using 2.6.29.3 (plus my hacks, but no changes to ixgbe for what that's worth).

I just got some new hardware:  Dual Intel E5530 processors, 12GB RAM, etc
and put in a dual-port 10G NIC with Intel chipset (though made by Silicom).

I tried changing MTU from 1500 to 9000 and started pktgen, and I noticed that a process
that does ethtool ioctls was using 99% of a CPU and strace showed
nothing (and would not ctrl-C to exit).  I have modified pktgen, btw.

Some other applications hung as well, and I found this in the logs.

There is a lot of new stuff in my setup, and this could be symptom instead
of cause, but thought I'd post the trace in case it helps.

ixgbe: eth1: ixgbe_change_mtu: changing MTU from 1500 to 9000
------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-2.6.dev.28/net/sched/sch_generic.c:226 dev_watchdog+0xe7/0x148()
Hardware name: X8DTU
NETDEV WATCHDOG: eth1 (ixgbe): transmit timed out
Modules linked in: nf_defrag_ipv4 nfs lockd nfs_acl auth_rpcgss 8021q garp redirdev arc4 michael_mic macvlan wanlink(P) pktgen stp bnep sco l2cap bluetooth 
sunrpc ipv6 cpufreq_ondemand acpi_cpufreq freq_table loop dm_multipath scsi_dh uinput pcspkr sg i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support e1000e ixgbe igb 
dca inet_lro button sr_mod cdrom joydev dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod ata_piix ata_generic pata_acpi libata sd_mod scsi_mod ext3 
jbd mbcache uhci_hcd ohci_hcd ssb ehci_hcd [last unloaded: x_tables]
Pid: 0, comm: swapper Tainted: P        W  2.6.29.3 #4
Call Trace:
  <IRQ>  [<ffffffff8103e67a>] warn_slowpath+0xd3/0xf2
  [<ffffffff810306bb>] ? __enqueue_entity+0x74/0x76
  [<ffffffff81032369>] ? enqueue_entity+0x1a0/0x1a9
  [<ffffffff8103240a>] ? enqueue_task_fair+0x3e/0x43
  [<ffffffff812c49ce>] ? _spin_unlock_irqrestore+0x40/0x44
  [<ffffffff8102fd3a>] ? task_rq_unlock+0xc/0xe
  [<ffffffff8103a39b>] ? try_to_wake_up+0x2a7/0x2b9
  [<ffffffff810519e0>] ? autoremove_wake_function+0x11/0x38
  [<ffffffff81011a1c>] ? __cycles_2_ns+0x23/0x42
  [<ffffffff812c46d0>] ? _spin_lock+0x1e/0x22
  [<ffffffff812c4925>] ? _spin_unlock+0x2d/0x38
  [<ffffffff812526a0>] ? __netif_tx_unlock+0x14/0x16
  [<ffffffff812526ef>] ? netif_tx_lock+0x4d/0x66
  [<ffffffff81252772>] ? dev_watchdog+0x0/0x148
  [<ffffffff81252859>] dev_watchdog+0xe7/0x148
  [<ffffffff81053d28>] ? hrtimer_hres_active+0x1a/0x30
  [<ffffffff8104728b>] run_timer_softirq+0x126/0x19c
  [<ffffffff81043332>] __do_softirq+0x66/0xe8
  [<ffffffff8100d36c>] call_softirq+0x1c/0x34
  [<ffffffff8100e5b4>] do_softirq+0x34/0x78
  [<ffffffff8104321f>] irq_exit+0x36/0x8a
  [<ffffffff8101bea4>] smp_apic_timer_interrupt+0x76/0x83
  [<ffffffff8100cda3>] apic_timer_interrupt+0x13/0x20
  <EOI>  [<ffffffff811a1009>] ? acpi_idle_enter_bm+0x236/0x26d
  [<ffffffff811a0fff>] ? acpi_idle_enter_bm+0x22c/0x26d
  [<ffffffff8121d5cc>] ? cpuidle_idle_call+0x80/0xb8
  [<ffffffff8100ab77>] ? cpu_idle+0x4f/0x92
  [<ffffffff812be8b3>] ? start_secondary+0x181/0x186
---[ end trace 8256d1ae7f76313d ]---

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

