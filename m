From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: BUG: NAPI mode broken in ucc_geth
Date: Tue, 19 Dec 2006 15:48:23 +0100
Message-ID: <1166539703.30422.111.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: 'linuxppc-dev Development' <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 147.175.241.83.in-addr.dgcsystems.net ([83.241.175.147]:28074
	"EHLO tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932819AbWLSOsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 09:48:25 -0500
To: Timur Tabi <timur@freescale.com>, Netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enabling NAPI for ucc_geth results in:
Looking up port of RPC 100003/2 on 192.168.1.15
NETDEV WATCHDOG: eth1: transmit timed out
------------[ cut here ]------------
Badness at c003af24 [verbose debug info unavailable]
Call Trace:
[C0247C00] [C00085B8] show_stack+0x48/0x194 (unreliable)
[C0247C30] [C00F19AC] report_bug+0x84/0xac
[C0247C40] [C000DD28] program_check_exception+0xe0/0x538
[C0247C80] [C000F78C] ret_from_except_full+0x0/0x4c
--- Exception: 700 at free_irq+0x20/0x110
    LR = ucc_geth_stop+0x98/0x108
[C0247D40] [C0017B34] __wake_up_common+0x58/0x94 (unreliable)
[C0247D60] [C011C4C8] ucc_geth_stop+0x98/0x108
[C0247D80] [C011DF1C] ucc_geth_timeout+0x5c/0x8c
[C0247D90] [C0164864] dev_watchdog+0xa0/0x108
[C0247DB0] [C002523C] run_timer_softirq+0xe4/0x1bc
[C0247DF0] [C00212C4] __do_softirq+0x80/0xe4
[C0247E20] [C0005778] do_softirq+0x58/0x60
[C0247E30] [C0021370] irq_exit+0x48/0x58
[C0247E40] [C000C398] timer_interrupt+0x26c/0x5fc
[C0247EE0] [C000F7D8] ret_from_except+0x0/0x14
--- Exception: 901 at cpu_idle+0xc8/0xf0
    LR = cpu_idle+0xec/0xf0
[C0247FC0] [C000388C] rest_init+0x28/0x38
[C0247FD0] [C02116AC] start_kernel+0x1d8/0x228
[C0247FF0] [00003438] 0x3438
Trying to free already-free IRQ 34
------------[ cut here ]------------
Badness at c003af24 [verbose debug info unavailable]
Call Trace:
[C0247C00] [C00085B8] show_stack+0x48/0x194 (unreliable)
[C0247C30] [C00F19AC] report_bug+0x84/0xac
[C0247C40] [C000DD28] program_check_exception+0xe0/0x538
[C0247C80] [C000F78C] ret_from_except_full+0x0/0x4c
--- Exception: 700 at free_irq+0x20/0x110
    LR = ucc_geth_stop+0xb8/0x108
[C0247D40] [C003AFE8] free_irq+0xe4/0x110 (unreliable)
[C0247D60] [C011C4E8] ucc_geth_stop+0xb8/0x108
[C0247D80] [C011DF1C] ucc_geth_timeout+0x5c/0x8c
[C0247D90] [C0164864] dev_watchdog+0xa0/0x108
[C0247DB0] [C002523C] run_timer_softirq+0xe4/0x1bc
[C0247DF0] [C00212C4] __do_softirq+0x80/0xe4
[C0247E20] [C0005778] do_softirq+0x58/0x60
[C0247E30] [C0021370] irq_exit+0x48/0x58
[C0247E40] [C000C398] timer_interrupt+0x26c/0x5fc
[C0247EE0] [C000F7D8] ret_from_except+0x0/0x14
--- Exception: 901 at cpu_idle+0xc8/0xf0
    LR = cpu_idle+0xec/0xf0
[C0247FC0] [C000388C] rest_init+0x28/0x38
[C0247FD0] [C02116AC] start_kernel+0x1d8/0x228
[C0247FF0] [00003438] 0x3438
------------[ cut here ]------------
Kernel BUG at c00513cc [verbose debug info unavailable]
Oops: Exception in kernel mode, sig: 5 [#1]

NIP: C00513CC LR: C001145C CTR: 00000000
REGS: c0247c00 TRAP: 0700   Not tainted  (2.6.19)
MSR: 00029032 <EE,ME,IR,DR>  CR: 24028044  XER: 00000000
TASK = c0234088[0] 'swapper' THREAD: c0246000
GPR00: 00000100 C0247CB0 C0234088 00001000 00000001 C9000000 FDEFB000
FFFFFFFF 
GPR08: 000000D0 C0246000 00000030 00000000 C025766C E0110000 C0253120
007FFF00 
GPR16: 0FFF7B68 00000000 00000002 C0250000 C0247EF0 00000000 3238BE5C
C0250000 
GPR24: C0247D38 C0250000 00000001 FDEFB000 00001000 00000001 00001000
C0263124 
NIP [C00513CC] __get_vm_area_node+0x2c/0x1c0
LR [C001145C] __ioremap+0x128/0x168
Call Trace:
[C0247CB0] [C00F271C] idr_remove+0x1c4/0x234 (unreliable)
[C0247CD0] [C001145C] __ioremap+0x128/0x168
[C0247D00] [C0015D1C] ucc_fast_init+0xf4/0x484
[C0247D30] [C011C794] ucc_geth_startup+0x25c/0x1980
[C0247D80] [C011DF24] ucc_geth_timeout+0x64/0x8c
[C0247D90] [C0164864] dev_watchdog+0xa0/0x108
[C0247DB0] [C002523C] run_timer_softirq+0xe4/0x1bc
[C0247DF0] [C00212C4] __do_softirq+0x80/0xe4
[C0247E20] [C0005778] do_softirq+0x58/0x60
[C0247E30] [C0021370] irq_exit+0x48/0x58
[C0247E40] [C000C398] timer_interrupt+0x26c/0x5fc
[C0247EE0] [C000F7D8] ret_from_except+0x0/0x14
--- Exception: 901 at cpu_idle+0xc8/0xf0
    LR = cpu_idle+0xec/0xf0
[C0247FC0] [C000388C] rest_init+0x28/0x38
[C0247FD0] [C02116AC] start_kernel+0x1d8/0x228
[C0247FF0] [00003438] 0x3438
Instruction dump:
4bffff20 7c0802a6 9421ffe0 bf410008 7c7e1b78 7c9a2378 7cdb3378 90010024 
3ba00001 54290024 8009000c 5400012e <0f000000> 70800001 41820020
7c600034 
 <0>Kernel panic - not syncing: Fatal exception in interrupt
 <0>Rebooting in 180 seconds..
