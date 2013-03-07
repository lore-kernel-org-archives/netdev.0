From: Daniel J Blueman <daniel@numascale-asia.com>
Subject: Re: BCM5709 hang and state dump...
Date: Thu, 07 Mar 2013 18:27:14 +0800
Message-ID: <51386B82.5050900@numascale-asia.com>
References: <5125B01E.4090405@numascale-asia.com> <1361483951.2240.44.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <5126D912.9000800@numascale-asia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Steffen Persvold <sp@numascale.com>, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:65406 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800Ab3CGK1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 05:27:19 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so365107pad.38
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 02:27:18 -0800 (PST)
In-Reply-To: <5126D912.9000800@numascale-asia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/02/2013 10:33, Daniel J Blueman wrote:
> Hi Michael,
>
> Thanks for your reply.
>
> We'll probably be able to reproduce it next week and collect the output
> with your debug patches if useful.
>
> Thanks again,
>    Daniel
>
> On 22/02/2013 05:59, Michael Chan wrote:
>> On Thu, 2013-02-21 at 13:26 +0800, Daniel J Blueman wrote:
>>> Hi Michael/Eilon,
>>>
>>> On a large system with 552 cores, 1.5TB memory and linux 3.7, under some
>>> particular workloads, we've seem the Broadcom 5709 network controller
>>> hang [1]. It's running boot code 6.2.0 and NCSI code 2.0.11.
>>>
>>> We suspect completion timeouts may be occurring due to possible
>>> starvation.
>>>
>>> Is there anything significant/indicative from the state dumped?
>>
>> The firmware state seems to be ok, although we see some MSIX interrupts
>> being asserted internally which is a sign that they don't get serviced.
>>
>> Is this easily reproducible?  Can we send you some debug patches to dump
>> more data?

We've hit this again [1], with 3.8.0 this time. Any success on the debug 
patches?

Many thanks,
   Daniel

--- [1]

WARNING: at net/sched/sch_generic.c:254 dev_watchdog+0x239/0x250()
Hardware name: IBM System X3755 M3 -[7164Z63]-
NETDEV WATCHDOG: eth0 (bnx2): transmit queue 3 timed out
Pid: 0, comm: swapper/0 Not tainted 3.8.0-advanced+ #2
Call Trace:
  <IRQ> [<ffffffff817a2889>] ? dev_watchdog+0x239/0x250
  [<ffffffff8105f914>] ? warn_slowpath_common+0x74/0xb0
  [<ffffffff8105f9c5>] ? warn_slowpath_fmt+0x45/0x50
  [<ffffffff817a2889>] ? dev_watchdog+0x239/0x250
  [<ffffffff817a2650>] ? pfifo_fast_dequeue+0xd0/0xd0
  [<ffffffff8106b4fa>] ? call_timer_fn.isra.27+0x2a/0x90
  [<ffffffff8106b6d4>] ? run_timer_softirq+0x174/0x240
  [<ffffffff810663b4>] ? __do_softirq+0xa4/0x150
  [<ffffffff81089005>] ? sched_clock_local+0x15/0x80
  [<ffffffff818670cc>] ? call_softirq+0x1c/0x30
  [<ffffffff81036eed>] ? do_softirq+0x4d/0x80
  [<ffffffff81066586>] ? irq_exit+0x86/0xa0
  [<ffffffff81866d67>] ? reschedule_interrupt+0x67/0x70
  <EOI> [<ffffffff81098ce0>] ? __tick_nohz_idle_enter+0x350/0x410
  [<ffffffff8103cda0>] ? default_idle+0x20/0x40
  [<ffffffff8103d686>] ? cpu_idle+0xb6/0xd0
  [<ffffffff81ee0adf>] ? start_kernel+0x322/0x32d
  [<ffffffff81ee05d5>] ? repair_env_string+0x5b/0x5b
---[ end trace 3d99e677c25b07a1 ]---
bnx2 0000:01:00.0 eth0: <--- start FTQ dump --->
bnx2 0000:01:00.0 eth0: RV2P_PFTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: RV2P_TFTQ_CTL 00020000
bnx2 0000:01:00.0 eth0: RV2P_MFTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: TBDR_FTQ_CTL 00004002
bnx2 0000:01:00.0 eth0: TDMA_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TXP_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TXP_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TPAT_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: RXP_CFTQ_CTL 00008000
bnx2 0000:01:00.0 eth0: RXP_FTQ_CTL 00100000
bnx2 0000:01:00.0 eth0: COM_COMXQ_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: COM_COMTQ_FTQ_CTL 00020000
bnx2 0000:01:00.0 eth0: COM_COMQ_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: CP_CPQ_FTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: CPU states:
bnx2 0000:01:00.0 eth0: 045000 mode b84c state 80001000 evt_mask 500 pc 
8001280 pc 8001280 instr 30820001
bnx2 0000:01:00.0 eth0: 085000 mode b84c state 80005000 evt_mask 500 pc 
8000a5c pc 8000a4c instr 1440fffc
bnx2 0000:01:00.0 eth0: 0c5000 mode b84c state 80001000 evt_mask 500 pc 
8004c14 pc 8004c10 instr 8e900000
bnx2 0000:01:00.0 eth0: 105000 mode b8cc state 80000000 evt_mask 500 pc 
8000a9c pc 8000a94 instr 8c420020
bnx2 0000:01:00.0 eth0: 145000 mode b880 state 80000000 evt_mask 500 pc 
800b13c pc 800b13c instr 8f4201c8
bnx2 0000:01:00.0 eth0: 185000 mode b8cc state 80004000 evt_mask 500 pc 
8000c6c pc 8000c50 instr 3c058000
bnx2 0000:01:00.0 eth0: <--- end FTQ dump --->
bnx2 0000:01:00.0 eth0: <--- start TBDC dump --->
bnx2 0000:01:00.0 eth0: TBDC free cnt: 32
bnx2 0000:01:00.0 eth0: LINE   CID BIDX  CMD VALIDS
bnx2 0000:01:00.0 eth0: 00  000800 a090  00  [0]
bnx2 0000:01:00.0 eth0: 01  000800 a090  00  [0]
bnx2 0000:01:00.0 eth0: 02  001100 9cf8  00  [0]
bnx2 0000:01:00.0 eth0: 03  0ddd00 fb58  fd  [0]
bnx2 0000:01:00.0 eth0: 04  1fff80 ffc8  6f  [0]
bnx2 0000:01:00.0 eth0: 05  0e9f80 9fa8  cf  [0]
bnx2 0000:01:00.0 eth0: 06  1d7380 f7e8  ff  [0]
bnx2 0000:01:00.0 eth0: 07  1d5f00 7bb0  bb  [0]
bnx2 0000:01:00.0 eth0: 08  1edb80 ef78  6f  [0]
bnx2 0000:01:00.0 eth0: 09  1e9e80 ee58  9e  [0]
bnx2 0000:01:00.0 eth0: 0a  17e780 fff8  7c  [0]
bnx2 0000:01:00.0 eth0: 0b  1d7e00 7db8  fc  [0]
bnx2 0000:01:00.0 eth0: 0c  1f7780 bff8  cf  [0]
bnx2 0000:01:00.0 eth0: 0d  1bff80 fff8  ff  [0]
bnx2 0000:01:00.0 eth0: 0e  17ff80 3de8  fe  [0]
bnx2 0000:01:00.0 eth0: 0f  1ff780 9cf0  ff  [0]
bnx2 0000:01:00.0 eth0: 10  1f7f80 ff58  ef  [0]
bnx2 0000:01:00.0 eth0: 11  1e7780 eaa8  7f  [0]
bnx2 0000:01:00.0 eth0: 12  1f9d80 f5e8  f7  [0]
bnx2 0000:01:00.0 eth0: 13  07ef80 ffc8  77  [0]
bnx2 0000:01:00.0 eth0: 14  1fb780 57e8  bf  [0]
bnx2 0000:01:00.0 eth0: 15  0fae80 df68  5f  [0]
bnx2 0000:01:00.0 eth0: 16  0fff80 7ff8  ae  [0]
bnx2 0000:01:00.0 eth0: 17  1fff80 fed8  c6  [0]
bnx2 0000:01:00.0 eth0: 18  03e380 fe70  7b  [0]
bnx2 0000:01:00.0 eth0: 19  0bcd80 7db8  7f  [0]
bnx2 0000:01:00.0 eth0: 1a  0ab180 bbd0  ef  [0]
bnx2 0000:01:00.0 eth0: 1b  0dfd80 db78  db  [0]
bnx2 0000:01:00.0 eth0: 1c  0bff80 7ff8  f3  [0]
bnx2 0000:01:00.0 eth0: 1d  0dfb80 f9f8  fc  [0]
bnx2 0000:01:00.0 eth0: 1e  1a6e80 9be8  f7  [0]
bnx2 0000:01:00.0 eth0: 1f  1fab80 db78  50  [0]
bnx2 0000:01:00.0 eth0: <--- end TBDC dump --->
bnx2 0000:01:00.0 eth0: DEBUG: intr_sem[0] PCI_CMD[00100546]
bnx2 0000:01:00.0 eth0: DEBUG: PCI_PM[19002008] PCI_MISC_CFG[92000088]
bnx2 0000:01:00.0 eth0: DEBUG: EMAC_TX_STATUS[00000008] 
EMAC_RX_STATUS[00000000]
bnx2 0000:01:00.0 eth0: DEBUG: RPM_MGMT_PKT_CTRL[40000088]
bnx2 0000:01:00.0 eth0: DEBUG: HC_STATS_INTERRUPT_STATUS[01b2004d]
bnx2 0000:01:00.0 eth0: DEBUG: PBA[00000000]
bnx2 0000:01:00.0 eth0: <--- start MCP states dump --->
bnx2 0000:01:00.0 eth0: DEBUG: MCP_STATE_P0[0003610e] MCP_STATE_P1[0003610e]
bnx2 0000:01:00.0 eth0: DEBUG: MCP mode[0000b880] state[80000000] 
evt_mask[00000500]
bnx2 0000:01:00.0 eth0: DEBUG: pc[08001e3c] pc[0800d994] instr[27bd0020]
bnx2 0000:01:00.0 eth0: DEBUG: shmem states:
bnx2 0000:01:00.0 eth0: DEBUG: drv_mb[01030003] fw_mb[00000003] 
link_status[8000006f]
  drv_pulse_mb[0000431d]
bnx2 0000:01:00.0 eth0: DEBUG: dev_info_signature[44564903] 
reset_type[01005254]
  condition[0003610e]
bnx2 0000:01:00.0 eth0: DEBUG: 000001c0: 01005254 42530088 0003610e 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 000003cc: 44444444 44444444 44444444 00000a14
bnx2 0000:01:00.0 eth0: DEBUG: 000003dc: 0004ffff 00000000 00000000 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 000003ec: 00000000 00000000 00000000 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 0x3fc[0000ffff]
bnx2 0000:01:00.0 eth0: <--- end MCP states dump --->
bnx2 0000:01:00.0 eth0: NIC Copper Link is Down
bnx2 0000:01:00.0 eth0: NIC Copper Link is Up, 1000 Mbps full duplex

bnx2 0000:01:00.0 eth0: <--- start FTQ dump --->
bnx2 0000:01:00.0 eth0: RV2P_PFTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: RV2P_TFTQ_CTL 00020000
bnx2 0000:01:00.0 eth0: RV2P_MFTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: TBDR_FTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: TDMA_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TXP_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TXP_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TPAT_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: RXP_CFTQ_CTL 00008000
bnx2 0000:01:00.0 eth0: RXP_FTQ_CTL 00100000
bnx2 0000:01:00.0 eth0: COM_COMXQ_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: COM_COMTQ_FTQ_CTL 00020000
bnx2 0000:01:00.0 eth0: COM_COMQ_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: CP_CPQ_FTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: CPU states:
bnx2 0000:01:00.0 eth0: 045000 mode b84c state 80001000 evt_mask 500 pc 
8001280 pc 8001288 instr 30820001
bnx2 0000:01:00.0 eth0: 085000 mode b84c state 80009000 evt_mask 500 pc 
8000a5c pc 8000a5c instr 10400016
bnx2 0000:01:00.0 eth0: 0c5000 mode b84c state 80001000 evt_mask 500 pc 
8004c20 pc 8004c1c instr 10e00088
bnx2 0000:01:00.0 eth0: 105000 mode b8cc state 80000000 evt_mask 500 pc 
8000a98 pc 8000a9c instr 8821
bnx2 0000:01:00.0 eth0: 145000 mode b880 state 80000000 evt_mask 500 pc 
8000058 pc 800d930 instr afb00028
bnx2 0000:01:00.0 eth0: 185000 mode b8cc state 80000000 evt_mask 500 pc 
8000918 pc 8000c58 instr 10a30010
bnx2 0000:01:00.0 eth0: <--- end FTQ dump --->
bnx2 0000:01:00.0 eth0: <--- start TBDC dump --->
bnx2 0000:01:00.0 eth0: TBDC free cnt: 32
bnx2 0000:01:00.0 eth0: LINE   CID BIDX  CMD VALIDS
bnx2 0000:01:00.0 eth0: 00  001200 0038  00  [0]
bnx2 0000:01:00.0 eth0: 01  000800 01e8  00  [0]
bnx2 0000:01:00.0 eth0: 02  001100 9cf8  00  [0]
bnx2 0000:01:00.0 eth0: 03  0ddd00 fb58  fd  [0]
bnx2 0000:01:00.0 eth0: 04  1fff80 ffc8  6f  [0]
bnx2 0000:01:00.0 eth0: 05  0e9f80 9fa8  cf  [0]
bnx2 0000:01:00.0 eth0: 06  1d7380 f7e8  ff  [0]
bnx2 0000:01:00.0 eth0: 07  1d5f00 7bb0  bb  [0]
bnx2 0000:01:00.0 eth0: 08  1edb80 ef78  6f  [0]
bnx2 0000:01:00.0 eth0: 09  1e9e80 ee58  9e  [0]
bnx2 0000:01:00.0 eth0: 0a  17e780 fff8  7c  [0]
bnx2 0000:01:00.0 eth0: 0b  1d7e00 7db8  fc  [0]
bnx2 0000:01:00.0 eth0: 0c  1f7780 bff8  cf  [0]
bnx2 0000:01:00.0 eth0: 0d  1bff80 fff8  ff  [0]
bnx2 0000:01:00.0 eth0: 0e  17ff80 3de8  fe  [0]
bnx2 0000:01:00.0 eth0: 0f  1ff780 9cf0  ff  [0]
bnx2 0000:01:00.0 eth0: 10  1f7f80 ff58  ef  [0]
bnx2 0000:01:00.0 eth0: 11  1e7780 eaa8  7f  [0]
bnx2 0000:01:00.0 eth0: 12  1f9d80 f5e8  f7  [0]
bnx2 0000:01:00.0 eth0: 13  07ef80 ffc8  77  [0]
bnx2 0000:01:00.0 eth0: 14  1fb780 57e8  bf  [0]
bnx2 0000:01:00.0 eth0: 15  0fae80 df68  5f  [0]
bnx2 0000:01:00.0 eth0: 16  0fff80 7ff8  ae  [0]
bnx2 0000:01:00.0 eth0: 17  1fff80 fed8  c6  [0]
bnx2 0000:01:00.0 eth0: 18  03e380 fe70  7b  [0]
bnx2 0000:01:00.0 eth0: 19  0bcd80 7db8  7f  [0]
bnx2 0000:01:00.0 eth0: 1a  0ab180 bbd0  ef  [0]
bnx2 0000:01:00.0 eth0: 1b  0dfd80 db78  db  [0]
bnx2 0000:01:00.0 eth0: 1c  0bff80 7ff8  f3  [0]
bnx2 0000:01:00.0 eth0: 1d  0dfb80 f9f8  fc  [0]
bnx2 0000:01:00.0 eth0: 1e  1a6e80 9be8  f7  [0]
bnx2 0000:01:00.0 eth0: 1f  1fab80 db78  50  [0]
bnx2 0000:01:00.0 eth0: <--- end TBDC dump --->
bnx2 0000:01:00.0 eth0: DEBUG: intr_sem[0] PCI_CMD[00100546]
bnx2 0000:01:00.0 eth0: DEBUG: PCI_PM[19002008] PCI_MISC_CFG[92000088]
bnx2 0000:01:00.0 eth0: DEBUG: EMAC_TX_STATUS[00000008] 
EMAC_RX_STATUS[00000000]
bnx2 0000:01:00.0 eth0: DEBUG: RPM_MGMT_PKT_CTRL[40000088]
bnx2 0000:01:00.0 eth0: DEBUG: HC_STATS_INTERRUPT_STATUS[01c0003f]
bnx2 0000:01:00.0 eth0: DEBUG: PBA[00000000]
bnx2 0000:01:00.0 eth0: <--- start MCP states dump --->
bnx2 0000:01:00.0 eth0: DEBUG: MCP_STATE_P0[0003610e] MCP_STATE_P1[0003610e]
bnx2 0000:01:00.0 eth0: DEBUG: MCP mode[0000b880] state[80000000] 
evt_mask[00000500]
bnx2 0000:01:00.0 eth0: DEBUG: pc[0800d994] pc[0800b3a4] instr[8f420388]
bnx2 0000:01:00.0 eth0: DEBUG: shmem states:
bnx2 0000:01:00.0 eth0: DEBUG: drv_mb[01030006] fw_mb[00000006] 
link_status[8000006f]
  drv_pulse_mb[000043f8]
bnx2 0000:01:00.0 eth0: DEBUG: dev_info_signature[44564903] 
reset_type[01005254]
  condition[0003610e]
bnx2 0000:01:00.0 eth0: DEBUG: 000001c0: 01005254 42530085 0003610e 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 000003cc: 44444444 44444444 44444444 00000a14
bnx2 0000:01:00.0 eth0: DEBUG: 000003dc: 0004ffff 00000000 00000000 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 000003ec: 00000000 00000000 00000000 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 0x3fc[0000ffff]
bnx2 0000:01:00.0 eth0: <--- end MCP states dump --->
bnx2 0000:01:00.0 eth0: NIC Copper Link is Down
bnx2 0000:01:00.0 eth0: NIC Copper Link is Up, 1000 Mbps full duplex

bnx2 0000:01:00.0 eth0: <--- start FTQ dump --->
bnx2 0000:01:00.0 eth0: RV2P_PFTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: RV2P_TFTQ_CTL 00020000
bnx2 0000:01:00.0 eth0: RV2P_MFTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: TBDR_FTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: TDMA_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TXP_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TXP_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: TPAT_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: RXP_CFTQ_CTL 00008000
bnx2 0000:01:00.0 eth0: RXP_FTQ_CTL 00100000
bnx2 0000:01:00.0 eth0: COM_COMXQ_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: COM_COMTQ_FTQ_CTL 00020000
bnx2 0000:01:00.0 eth0: COM_COMQ_FTQ_CTL 00010000
bnx2 0000:01:00.0 eth0: CP_CPQ_FTQ_CTL 00004000
bnx2 0000:01:00.0 eth0: CPU states:
bnx2 0000:01:00.0 eth0: 045000 mode b84c state 80001000 evt_mask 500 pc 
8001284 pc 8001284 instr 8e260000
bnx2 0000:01:00.0 eth0: 085000 mode b84c state 80001000 evt_mask 500 pc 
8000a4c pc 8000a5c instr 10400016
bnx2 0000:01:00.0 eth0: 0c5000 mode b84c state 80001000 evt_mask 500 pc 
8004c14 pc 8004c18 instr 32050003
bnx2 0000:01:00.0 eth0: 105000 mode b8cc state 80000000 evt_mask 500 pc 
8000a90 pc 8000a98 instr 3c020800
bnx2 0000:01:00.0 eth0: 145000 mode b880 state 80000000 evt_mask 500 pc 
800af54 pc 8003e30 instr 9062004d
bnx2 0000:01:00.0 eth0: 185000 mode b8cc state 80000000 evt_mask 500 pc 
8000c7c pc 8000c6c instr 8ce800e8
bnx2 0000:01:00.0 eth0: <--- end FTQ dump --->
bnx2 0000:01:00.0 eth0: <--- start TBDC dump --->
bnx2 0000:01:00.0 eth0: TBDC free cnt: 32
bnx2 0000:01:00.0 eth0: LINE   CID BIDX  CMD VALIDS
bnx2 0000:01:00.0 eth0: 00  001200 0008  00  [0]
bnx2 0000:01:00.0 eth0: 01  001100 0010  00  [0]
bnx2 0000:01:00.0 eth0: 02  001100 9cf8  00  [0]
bnx2 0000:01:00.0 eth0: 03  0ddd00 fb58  fd  [0]
bnx2 0000:01:00.0 eth0: 04  1fff80 ffc8  6f  [0]
bnx2 0000:01:00.0 eth0: 05  0e9f80 9fa8  cf  [0]
bnx2 0000:01:00.0 eth0: 06  1d7380 f7e8  ff  [0]
bnx2 0000:01:00.0 eth0: 07  1d5f00 7bb0  bb  [0]
bnx2 0000:01:00.0 eth0: 08  1edb80 ef78  6f  [0]
bnx2 0000:01:00.0 eth0: 09  1e9e80 ee58  9e  [0]
bnx2 0000:01:00.0 eth0: 0a  17e780 fff8  7c  [0]
bnx2 0000:01:00.0 eth0: 0b  1d7e00 7db8  fc  [0]
bnx2 0000:01:00.0 eth0: 0c  1f7780 bff8  cf  [0]
bnx2 0000:01:00.0 eth0: 0d  1bff80 fff8  ff  [0]
bnx2 0000:01:00.0 eth0: 0e  17ff80 3de8  fe  [0]
bnx2 0000:01:00.0 eth0: 0f  1ff780 9cf0  ff  [0]
bnx2 0000:01:00.0 eth0: 10  1f7f80 ff58  ef  [0]
bnx2 0000:01:00.0 eth0: 11  1e7780 eaa8  7f  [0]
bnx2 0000:01:00.0 eth0: 12  1f9d80 f5e8  f7  [0]
bnx2 0000:01:00.0 eth0: 13  07ef80 ffc8  77  [0]
bnx2 0000:01:00.0 eth0: 14  1fb780 57e8  bf  [0]
bnx2 0000:01:00.0 eth0: 15  0fae80 df68  5f  [0]
bnx2 0000:01:00.0 eth0: 16  0fff80 7ff8  ae  [0]
bnx2 0000:01:00.0 eth0: 17  1fff80 fed8  c6  [0]
bnx2 0000:01:00.0 eth0: 18  03e380 fe70  7b  [0]
bnx2 0000:01:00.0 eth0: 19  0bcd80 7db8  7f  [0]
bnx2 0000:01:00.0 eth0: 1a  0ab180 bbd0  ef  [0]
bnx2 0000:01:00.0 eth0: 1b  0dfd80 db78  db  [0]
bnx2 0000:01:00.0 eth0: 1c  0bff80 7ff8  f3  [0]
bnx2 0000:01:00.0 eth0: 1d  0dfb80 f9f8  fc  [0]
bnx2 0000:01:00.0 eth0: 1e  1a6e80 9be8  f7  [0]
bnx2 0000:01:00.0 eth0: 1f  1fab80 db78  50  [0]
bnx2 0000:01:00.0 eth0: <--- end TBDC dump --->
bnx2 0000:01:00.0 eth0: DEBUG: intr_sem[0] PCI_CMD[00100546]
bnx2 0000:01:00.0 eth0: DEBUG: PCI_PM[19002008] PCI_MISC_CFG[92000088]
bnx2 0000:01:00.0 eth0: DEBUG: EMAC_TX_STATUS[00000008] 
EMAC_RX_STATUS[00000000]
bnx2 0000:01:00.0 eth0: DEBUG: RPM_MGMT_PKT_CTRL[40000088]
bnx2 0000:01:00.0 eth0: DEBUG: HC_STATS_INTERRUPT_STATUS[014600b9]
bnx2 0000:01:00.0 eth0: DEBUG: PBA[00000000]
bnx2 0000:01:00.0 eth0: <--- start MCP states dump --->
bnx2 0000:01:00.0 eth0: DEBUG: MCP_STATE_P0[0003610e] MCP_STATE_P1[0003610e]
bnx2 0000:01:00.0 eth0: DEBUG: MCP mode[0000b880] state[80000000] 
evt_mask[00000500]
bnx2 0000:01:00.0 eth0: DEBUG: pc[08003d8c] pc[08000b10] instr[00021202]
bnx2 0000:01:00.0 eth0: DEBUG: shmem states:
bnx2 0000:01:00.0 eth0: DEBUG: drv_mb[01030009] fw_mb[00000009] 
link_status[8000006f]
  drv_pulse_mb[0000442d]
bnx2 0000:01:00.0 eth0: DEBUG: dev_info_signature[44564903] 
reset_type[01005254]
  condition[0003610e]
bnx2 0000:01:00.0 eth0: DEBUG: 000001c0: 01005254 42530085 0003610e 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 000003cc: 44444444 44444444 44444444 00000a14
bnx2 0000:01:00.0 eth0: DEBUG: 000003dc: 0004ffff 00000000 00000000 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 000003ec: 00000000 00000000 00000000 00000000
bnx2 0000:01:00.0 eth0: DEBUG: 0x3fc[0000ffff]
bnx2 0000:01:00.0 eth0: <--- end MCP states dump --->
bnx2 0000:01:00.0 eth0: NIC Copper Link is Down
bnx2 0000:01:00.0 eth0: NIC Copper Link is Up, 1000 Mbps full duplex
-- 
Daniel J Blueman
Principal Software Engineer, Numascale Asia
