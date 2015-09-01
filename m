From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH 1/2] net: Remove ndo_xmit_flush netdev operation, use
 signalling instead.
Date: Tue, 1 Sep 2015 15:10:23 +0800
Message-ID: <55E54F5F.9040603@windriver.com>
References: <20140825.163502.973913220915588977.davem@davemloft.net>	<55E549CE.4010509@windriver.com> <20150901.000051.2053259950492309439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <therbert@google.com>,
	<jhs@mojatatu.com>, <hannes@stressinduktion.org>,
	<edumazet@google.com>, <jeffrey.t.kirsher@intel.com>,
	<rusty@rustcorp.com.au>, <dborkman@redhat.com>, <brouer@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64303 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbbIAHKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 03:10:38 -0400
In-Reply-To: <20150901.000051.2053259950492309439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2015 03:00 PM, David Miller wrote:
> From: yzhu1 <Yanjun.Zhu@windriver.com>
> Date: Tue, 1 Sep 2015 14:46:38 +0800
>
>> After I applied this patch, the skb->xmit_more is not always zero.
> There have been thousands upon thousands of commits since that
> change.
>
> You should be testing the tree as it currently stands, to see
> if xmit_more behaves correctly or not.
>
> If xmit_more were incorrectly set to 1 in the current tree, it
> would stall the TX queue of the networking device and we would
> be seeing lots of reports of this.
>
>
Thanks for your reply.
Yes. After running for several days, the following messages will appear.

igb 0000:09:00.0: Detected Tx Unit Hang
   Tx Queue <1>
   TDH <1a>
   TDT <1a>
   next_to_use <1d>
   next_to_clean <1a>
buffer_info[next_to_clean]
   time_stamp <ffffeb7d>
   next_to_watch <ffff88103ee711c0>
   jiffies <fffff324>
   desc.status <0>
igb 0000:09:00.0: Detected Tx Unit Hang
   Tx Queue <1>
   TDH <1a>
   TDT <1a>
   next_to_use <1d>
   next_to_clean <1a>
buffer_info[next_to_clean]
   time_stamp <ffffeb7d>
   next_to_watch <ffff88103ee711c0>
   jiffies <fffffaf4>
   desc.status <0>
igb 0000:09:00.0: Detected Tx Unit Hang
   Tx Queue <1>
   TDH <1a>
   TDT <1a>
   next_to_use <1d>
   next_to_clean <1a>
buffer_info[next_to_clean]
   time_stamp <ffffeb7d>
   next_to_watch <ffff88103ee711c0>
   jiffies <1000002c4>
   desc.status <0>
igb 0000:09:00.0: Detected Tx Unit Hang
   Tx Queue <1>
   TDH <1a>
   TDT <1a>
   next_to_use <1d>------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264 
dev_watchdog+0x259/0x270()
NETDEV WATCHDOG: eth0 (igb): transmit queue 1 timed out
Modules linked in: x86_pkg_temp_thermal intel_powerclamp coretemp 
crct10dif_pclmul crct10dif_common aesni_intel aes_x86_64 glue_helper lrw 
gf128mul ablk_helper cryptd iTCO_wdt sb_edac iTCO_vendor_support ipmi_si 
edac_core i2c_i801 lpc_ich ipmi_msghandler nfsd fuse
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.29ltsi-WR7.0.0.0_standard #2
Hardware name: Intel Corporation S2600CP/S2600CP, BIOS 
RMLSDP.86I.R4.26.D674.1304190022 04/19/2013
  0000000000000009 ffff88081f603da0 ffffffff81ab9bb8 ffff88081f603de8
  ffff88081f603dd8 ffffffff8104c64d 0000000000000001 ffff880812f6d940
  0000000000000000 ffff880813efc000 0000000000000008 ffff88081f603e38
Call Trace:
  <IRQ> [<ffffffff81ab9bb8>] dump_stack+0x4e/0x7a
  [<ffffffff8104c64d>] warn_slowpath_common+0x7d/0xa0
  [<ffffffff8104c6bc>] warn_slowpath_fmt+0x4c/0x50
  [<ffffffff81ac09c7>] ? _raw_spin_unlock+0x17/0x30
  [<ffffffff81998659>] dev_watchdog+0x259/0x270
  [<ffffffff81998400>] ? dev_graft_qdisc+0x80/0x80
  [<ffffffff810594cb>] call_timer_fn+0x3b/0x170
  [<ffffffff81998400>] ? dev_graft_qdisc+0x80/0x80
  [<ffffffff81059d64>] run_timer_softirq+0x1c4/0x2d0
  [<ffffffff81051557>] __do_softirq+0xb7/0x2e0
  [<ffffffff810518be>] irq_exit+0x7e/0xa0
  [<ffffffff81acae74>] smp_apic_timer_interrupt+0x44/0x50
  [<ffffffff81ac9c4a>] apic_timer_interrupt+0x6a/0x70
  <EOI> [<ffffffff81880706>] ? cpuidle_enter_state+0x46/0xb0
  [<ffffffff8188082c>] cpuidle_idle_call+0xbc/0x250
  [<ffffffff8100cdce>] arch_cpu_idle+0xe/0x20
  [<ffffffff810a2bb5>] cpu_startup_entry+0x185/0x290
  [<ffffffff81ab4424>] rest_init+0x84/0x90
  [<ffffffff82333d50>] start_kernel+0x3d6/0x3e3
  [<ffffffff82333495>] x86_64_start_reservations+0x2a/0x2c
  [<ffffffff8233358e>] x86_64_start_kernel+0xf7/0xfa
---[ end trace 57ad9eaf9dd80dc2 ]---
igb 0000:09:00.0 eth0: Reset adapter
igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
igb 0000:09:00.0: Detected Tx Unit Hang

   next_to_clean <1a>
buffer_info[next_to_clean]
   time_stamp <ffffeb7d>
   next_to_watch <ffff88103ee711c0>
   jiffies <100000a94>
   desc.status <0>
