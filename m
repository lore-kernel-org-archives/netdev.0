From: "Chris Friesen" <cfriesen@nortel.com>
Subject: [BUG] oops in net_rx_action on 64-bit powerpc
Date: Thu, 23 Oct 2008 13:59:16 -0600
Message-ID: <4900D794.5020807@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:60176 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991AbYJWT7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 15:59:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried booting a post 2.6.27 -git on a Motorola ATCA6101 (very similar to a 
Maple board).  The first time I booted I got the first log below via the 
serial console.  I rebooted and got as far as a login prompt.  I was able to 
log in via the serial console, but then got an almost identical oops again, as 
shown in the second log below.

I configed out the gigE drivers for the backplane so the only remaining 
network link was the e100 link used for booting, but the problem remained.

Anyone have any idea what might be causing this?

Thanks,

Chris


Starting xinetd: [  OK  ]
Starting cron: [  OK  ]
Unable to handle kernel paging request for data at address 0x00100108
Faulting instruction address: 0xc00000000028c1cc
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=2 Maple
Modules linked in:
NIP: c00000000028c1cc LR: c00000000028c13c CTR: 0000000000000000
REGS: c00000000fff7b90 TRAP: 0300   Not tainted  (2.6.27-05329-g39076ba)
MSR: 9000000000009032 <EE,ME,IR,DR>  CR: 22ffff24  XER: 20000000
DAR: 0000000000100108, DSISR: 000000000a000000
TASK = c00000017a061080[0] 'swapper' THREAD: c00000017a078000 CPU: 1
GPR00: 0000000000000000 c00000000fff7e10 c00000000059bfe0 0000000000000020
GPR04: 0000000000000001 c000000178179800 c00000000027fda8 0000000000000000
GPR08: 0000000000000000 0000000000200200 0000000000000001 0000000000100100
GPR12: 0000000022ffff22 c0000000005bc500 0000000000000000 0000000000000000
GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
GPR20: 0000000000000000 000000000000000a 0000000000000001 0000000000000001
GPR24: c0000000005a2280 c0000000005f5134 00000000fffd9bbe 00000000000000ec
GPR28: c000000006e30c28 0000000000000020 c000000000543440 c00000017a279b40
NIP [c00000000028c1cc] .net_rx_action+0x1e4/0x26c
LR [c00000000028c13c] .net_rx_action+0x154/0x26c
Call Trace:
[c00000000fff7e10] [c00000000028c13c] .net_rx_action+0x154/0x26c (unreliable)
[c00000000fff7ec0] [c000000000056938] .__do_softirq+0xf8/0x1f4
[c00000000fff7f90] [c000000000024334] .call_do_softirq+0x14/0x24
[c00000017a07b970] [c00000000000bcdc] .do_softirq+0xf0/0x104
[c00000017a07ba10] [c000000000056ae8] .irq_exit+0x70/0x88
[c00000017a07ba90] [c00000000000ba18] .do_IRQ+0x14c/0x244
[c00000017a07bb30] [c000000000004710] hardware_interrupt_entry+0x18/0x1c
--- Exception: 501 at .raw_local_irq_restore+0x38/0x44
      LR = .cpu_idle+0xd8/0x154
[c00000017a07be20] [c000000000012068] .cpu_idle+0x118/0x154 (unreliable)
[c00000017a07bec0] [c0000000003d4304] .start_secondary+0x310/0x3e8
[c00000017a07bf90] [c0000000000072b4] .start_secondary_prolog+0x10/0x14
Instruction dump:
eb61ffd8 eb81ffe0 eba1ffe8 ebc1fff0 ebe1fff8 7c0803a6 4e800020 e81f0010
7809ffe3 40820038 e93f0008 e97f0000 <f92b0008> f9690000 e95c0008 fb9f0000




root@10:/root> uname -a
Linux 10.41.18.77 2.6.27-05329-g39076ba #1 SMP Tue Oct 21 16:46:06 CST 2008
ppc64 GNU/Linux
root@10:/root> Unable to handle kernel paging request for data at address
0x00100108
Faulting instruction address: 0xc00000000028c1cc
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=2 Maple
Modules linked in:
NIP: c00000000028c1cc LR: c00000000028c13c CTR: 0000000000000000
REGS: c00000000fff7b90 TRAP: 0300   Not tainted  (2.6.27-05329-g39076ba)
MSR: 9000000000009032 <EE,ME,IR,DR>  CR: 22ffff24  XER: 20000000
DAR: 0000000000100108, DSISR: 000000000a000000
TASK = c00000017a061080[0] 'swapper' THREAD: c00000017a078000 CPU: 1
GPR00: 0000000000000000 c00000000fff7e10 c00000000059bfe0 0000000000000020
GPR04: 0000000000000001 0000000000000001 c00000000027fda8 0000000000000000
GPR08: 0000000000000000 0000000000200200 0000000000000001 0000000000100100
GPR12: 0000000022ffff22 c0000000005bc500 0000000000000000 0000000000000000
GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
GPR20: 0000000000000000 000000000000000a 0000000000000001 0000000000000001
GPR24: c0000000005a2280 c0000000005f5134 00000001000387ff 000000000000010c
GPR28: c000000006e30c28 0000000000000020 c000000000543440 c00000017a2b0b40
NIP [c00000000028c1cc] .net_rx_action+0x1e4/0x26c
LR [c00000000028c13c] .net_rx_action+0x154/0x26c
Call Trace:
[c00000000fff7e10] [c00000000028c13c] .net_rx_action+0x154/0x26c (unreliable)
[c00000000fff7ec0] [c000000000056938] .__do_softirq+0xf8/0x1f4
[c00000000fff7f90] [c000000000024334] .call_do_softirq+0x14/0x24
[c00000017a07b970] [c00000000000bcdc] .do_softirq+0xf0/0x104
[c00000017a07ba10] [c000000000056ae8] .irq_exit+0x70/0x88
[c00000017a07ba90] [c00000000000ba18] .do_IRQ+0x14c/0x244
[c00000017a07bb30] [c000000000004710] hardware_interrupt_entry+0x18/0x1c
--- Exception: 501 at .cpu_idle+0xf0/0x154
      LR = .cpu_idle+0xd8/0x154
[c00000017a07be20] [c000000000012068] .cpu_idle+0x118/0x154 (unreliable)
[c00000017a07bec0] [c0000000003d4304] .start_secondary+0x310/0x3e8
[c00000017a07bf90] [c0000000000072b4] .start_secondary_prolog+0x10/0x14
Instruction dump:
eb61ffd8 eb81ffe0 eba1ffe8 ebc1fff0 ebe1fff8 7c0803a6 4e800020 e81f0010
7809ffe3 40820038 e93f0008 e97f0000 <f92b0008> f9690000 e95c0008 fb9f0000
