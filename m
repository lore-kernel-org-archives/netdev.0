From: Dave Jones <davej@codemonkey.org.uk>
Subject: I218 e1000e hangs.
Date: Thu, 13 Aug 2015 22:41:48 -0400
Message-ID: <20150814024148.GA2813@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:56910 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751AbbHNCmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 22:42:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got a machine with an onboard NIC that reproduces a hardware
hang every time I do an rsync to it.

[  488.752630] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <27>
  TDT                  <34>
  next_to_use          <34>
  next_to_clean        <23>
buffer_info[next_to_clean]:
  time_stamp           <1000048b2>
  next_to_watch        <27>
  jiffies              <1000049d8>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <7c00>
PHY Extended Status    <3000>
PCI Status             <10>
[  490.751948] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <27>
  TDT                  <34>
  next_to_use          <34>
  next_to_clean        <23>
buffer_info[next_to_clean]:
  time_stamp           <1000048b2>
  next_to_watch        <27>
  jiffies              <100004aa0>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <7c00>
PHY Extended Status    <3000>
PCI Status             <10>
[  492.750447] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <27>
  TDT                  <34>
  next_to_use          <34>
  next_to_clean        <23>
buffer_info[next_to_clean]:
  time_stamp           <1000048b2>
  next_to_watch        <27>
  jiffies              <100004b68>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <7c00>
PHY Extended Status    <3000>
PCI Status             <10>
[  494.749507] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <27>
  TDT                  <34>
  next_to_use          <34>
  next_to_clean        <23>
buffer_info[next_to_clean]:
  time_stamp           <1000048b2>
  next_to_watch        <27>
  jiffies              <100004c30>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <7c00>
PHY Extended Status    <3000>
PCI Status             <10>
[  494.758881] ------------[ cut here ]------------
[  494.759109] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:303 dev_watchdog+0x23a/0x250()
[  494.759347] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
[  494.759585] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.2.0-rc6-backup-debug+ #1
[  494.759841]  ffffffffb0ddd622 0431bce15e8d04e9 ffff88043d803d08 ffffffffb097e15b
[  494.760111]  0000000000000007 ffff88043d803d60 ffff88043d803d48 ffffffffb0076de5
[  494.760392]  0000000000000000 0000000000000000 0000000000000000 ffff880427bb7d30
[  494.760648] Call Trace:
[  494.760896]  <IRQ>  [<ffffffffb097e15b>] dump_stack+0x4c/0x65
[  494.761160]  [<ffffffffb0076de5>] warn_slowpath_common+0x85/0xc0
[  494.761423]  [<ffffffffb0076ea5>] warn_slowpath_fmt+0x55/0x70
[  494.761686]  [<ffffffffb087b02a>] dev_watchdog+0x23a/0x250
[  494.761949]  [<ffffffffb087adf0>] ? qdisc_rcu_free+0x40/0x40
[  494.762215]  [<ffffffffb00e9703>] call_timer_fn+0xb3/0x420
[  494.762483]  [<ffffffffb00e9655>] ? call_timer_fn+0x5/0x420
[  494.762753]  [<ffffffffb00e9c02>] run_timer_softirq+0x192/0x3d0
[  494.763025]  [<ffffffffb007b6b5>] ? __do_softirq+0xb5/0x5d0
[  494.763300]  [<ffffffffb087adf0>] ? qdisc_rcu_free+0x40/0x40
[  494.763570]  [<ffffffffb007b6df>] __do_softirq+0xdf/0x5d0
[  494.763838]  [<ffffffffb007bd58>] ? irq_exit+0x78/0xc0
[  494.764108]  [<ffffffffb007bd98>] irq_exit+0xb8/0xc0
[  494.764381]  [<ffffffffb098bee6>] smp_apic_timer_interrupt+0x46/0x60
[  494.764662]  [<ffffffffb098a8ad>] apic_timer_interrupt+0x6d/0x80
[  494.764943]  <EOI>  [<ffffffffb0815916>] ? cpuidle_enter_state+0x106/0x3a0
[  494.765232]  [<ffffffffb0815951>] ? cpuidle_enter_state+0x141/0x3a0
[  494.765525]  [<ffffffffb0815946>] ? cpuidle_enter_state+0x136/0x3a0
[  494.765815]  [<ffffffffb0815be7>] cpuidle_enter+0x17/0x20
[  494.766105]  [<ffffffffb00bca5c>] cpu_startup_entry+0x38c/0x500
[  494.766396]  [<ffffffffb0977988>] rest_init+0x138/0x140
[  494.766692]  [<ffffffffb0f91f23>] start_kernel+0x466/0x487
[  494.766990]  [<ffffffffb0f91495>] x86_64_start_reservations+0x2a/0x2c
[  494.767292]  [<ffffffffb0f91583>] x86_64_start_kernel+0xec/0xf0

Here's another instance after rebooting, with some different register states..

[ 2379.674285] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <50>
  TDT                  <5d>
  next_to_use          <5d>
  next_to_clean        <4d>
buffer_info[next_to_clean]:
  time_stamp           <100032c2d>
  next_to_watch        <50>
  jiffies              <100032ce8>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
[ 2381.672792] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <50>
  TDT                  <5d>
  next_to_use          <5d>
  next_to_clean        <4d>
buffer_info[next_to_clean]:
  time_stamp           <100032c2d>
  next_to_watch        <50>
  jiffies              <100032db0>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
[ 2383.671379] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <50>
  TDT                  <5d>
  next_to_use          <5d>
  next_to_clean        <4d>
buffer_info[next_to_clean]:
  time_stamp           <100032c2d>
  next_to_watch        <50>
  jiffies              <100032e78>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
[ 2385.669944] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <50>
  TDT                  <5d>
  next_to_use          <5d>
  next_to_clean        <4d>
buffer_info[next_to_clean]:
  time_stamp           <100032c2d>
  next_to_watch        <50>
  jiffies              <100032f40>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>
[ 2387.668428] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
  TDH                  <50>
  TDT                  <5d>
  next_to_use          <5d>
  next_to_clean        <4d>
buffer_info[next_to_clean]:
  time_stamp           <100032c2d>
  next_to_watch        <50>
  jiffies              <100033008>
  next_to_watch.status <0>
MAC Status             <80083>
PHY Status             <796d>
PHY 1000BASE-T Status  <3c00>
PHY Extended Status    <3000>
PCI Status             <10>


The rsync on the other side then craps itself detecting 'corrupted packets'.

The NIC in question is..

00:19.0 Ethernet controller: Intel Corporation Ethernet Connection (2) I218-V

If this is a software problem, it's not anything new. I tested as far back
as 3.16, which had the same problem.

Is there any hw feature I can try disabling, to see if that makes a difference ?

	Dave
