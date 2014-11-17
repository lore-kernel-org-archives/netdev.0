From: Rui Xiang <rui.xiang@huawei.com>
Subject: [BNX2] A Netdev Watchdog with kernel stable 3.4
Date: Mon, 17 Nov 2014 20:42:12 +0800
Message-ID: <5469ED24.7010008@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:63369 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbaKQMm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 07:42:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

On a system that was running stable 3.4.87, I got the below stack.
That was a NETDEV WATCHDOG. And we could also see watchdog timeouts with the 
BNX2. (After the stack, an oops occurred while running ifconfig. I think it 
would be related to this timeout.)

Otherwises, the bnx2_dump_state and bnx2_dump_mcp_state have printed the states. 
Through these states info, can we got the real situation of NIC1.
Or can we see what resulted the WATCHDOG, a bnx2 device fault or other reasons.

Thanks.


*The stack*:

 WARNING: at /usr/src/packages/BUILD/kernel-default-3.4.87/linux-3.4/net/sched/sch_generic.c:256 dev_watchdog+0x256/0x260()
 NETDEV WATCHDOG: NIC1 (bnx2): transmit queue 3 timed out
 Modules linked in: smb3_failover(O) smb2(O) smb(O) smb_manager(O) nfs(O) nfs_acl(O) nfsd(O) lockd(O) nal(O) auth_rpcgss(O) 
scsi_dh_hp_sw scsi_dh_alua scsi_dh_emc scsi_dh_rdac scsi_dh scsi_mod [last unloaded: ipmi_msghandler]
 Pid: 0, comm: swapper/0 Tainted: P        W  O 3.4.87-default #1
 Call Trace:
  <IRQ>  [<ffffffff8103fcea>] warn_slowpath_common+0x7a/0xb0
  [<ffffffff8103fdc1>] warn_slowpath_fmt+0x41/0x50
  [<ffffffff81047749>] ? raise_softirq_irqoff+0x9/0x30
  [<ffffffff813ae0f6>] dev_watchdog+0x256/0x260
  [<ffffffff813adea0>] ? dev_deactivate_queue.constprop.30+0x70/0x70
  [<ffffffff8104edc7>] run_timer_softirq+0x147/0x340
  [<ffffffff810470d8>] __do_softirq+0xc8/0x1e0
  [<ffffffff8109250f>] ? tick_program_event+0x1f/0x30
  [<ffffffff81460a6c>] call_softirq+0x1c/0x30
  [<ffffffff8100417d>] do_softirq+0x9d/0xd0
  [<ffffffff810474a5>] irq_exit+0xb5/0xc0
  [<ffffffff81021b49>] smp_apic_timer_interrupt+0x69/0xa0
  [<ffffffff8146006f>] apic_timer_interrupt+0x6f/0x80
  <EOI>  [<ffffffff81457bdd>] ? retint_restore_args+0x13/0x13
  [<ffffffff81360149>] ? poll_idle+0x49/0x90
  [<ffffffff8136011f>] ? poll_idle+0x1f/0x90
  [<ffffffff8135fcc9>] cpuidle_enter+0x19/0x20
  [<ffffffff813602f2>] cpuidle_idle_call+0xa2/0x250
  [<ffffffff8100b08f>] cpu_idle+0x6f/0xe0
  [<ffffffff81915960>] ? rawsock_init+0x12/0x12
  [<ffffffff814331c9>] rest_init+0x6d/0x74
  [<ffffffff818d3be5>] start_kernel+0x3a2/0x3af
  [<ffffffff818d3642>] ? repair_env_string+0x5e/0x5e
  [<ffffffff818d332a>] x86_64_start_reservations+0x131/0x135
  [<ffffffff818d342e>] x86_64_start_kernel+0x100/0x10f
 ---[ end trace 497e24e681e0c02d ]---
 bnx2 0000:05:00.1: NIC1: DEBUG: intr_sem[0] PCI_CMD[00100002]
 bnx2 0000:05:00.1: NIC1: DEBUG: PCI_PM[19002008] PCI_MISC_CFG[92000088]
 bnx2 0000:05:00.1: NIC1: DEBUG: EMAC_TX_STATUS[00000008] EMAC_RX_STATUS[00000000]
 bnx2 0000:05:00.1: NIC1: DEBUG: RPM_MGMT_PKT_CTRL[40000088]
 bnx2 0000:05:00.1: NIC1: DEBUG: HC_STATS_INTERRUPT_STATUS[01ff0000]
 bnx2 0000:05:00.1: NIC1: DEBUG: PBA[00000000]
 bnx2 0000:05:00.1: NIC1: <--- start MCP states dump --->
 bnx2 0000:05:00.1: NIC1: DEBUG: MCP_STATE_P0[0003e10e] MCP_STATE_P1[0003e10e]
 bnx2 0000:05:00.1: NIC1: DEBUG: MCP mode[0000b800] state[80008000] evt_mask[00000500]
 bnx2 0000:05:00.1: NIC1: DEBUG: pc[08008f60] pc[0800d21c] instr[00051080]
 bnx2 0000:05:00.1: NIC1: DEBUG: shmem states:
 bnx2 0000:05:00.1: NIC1: DEBUG: drv_mb[01030003] fw_mb[00000003] link_status[0000006f] drv_pulse_mb[0000073d]
 bnx2 0000:05:00.1: NIC1: DEBUG: dev_info_signature[44564907] reset_type[01005254] condition[0003e10e]
 bnx2 0000:05:00.1: NIC1: DEBUG: 000003cc: 00000000 00000000 00000000 00000000
 bnx2 0000:05:00.1: NIC1: DEBUG: 000003dc: 00000000 00000000 00000000 00000000
 bnx2 0000:05:00.1: NIC1: DEBUG: 000003ec: 00000000 00000000 00000000 00000000
 bnx2 0000:05:00.1: NIC1: DEBUG: 0x3fc[00000000]
 bnx2 0000:05:00.1: NIC1: <--- end MCP states dump --->
