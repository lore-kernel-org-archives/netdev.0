From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc5-mm1 regression - kernel warning on
 tcp_fastretrans_alert()
Date: Thu, 13 Dec 2007 11:55:26 -0800
Message-ID: <20071213115526.3b790bad.akpm@linux-foundation.org>
References: <20071213024050.7d6e5f3e.akpm@linux-foundation.org>
	<47614815.8070007@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50792 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762851AbXLMTzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 14:55:46 -0500
In-Reply-To: <47614815.8070007@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2007 20:26:21 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> Hi Andrew,

Hi.  Please do try to cc netdev@vger.kernel.org on net-related problems. 
Doing so will often save multiple hours latency and will optimise away one
entire email (ie: this one).

> Following call trace is seen in 2.6.24-rc5-mm1 kernel also,it was reported
> for 2.6.24-rc4-mm1 kernel http://lkml.org/lkml/2007/12/6/22
> 
> ls21b kernel: [ 7530.313408] WARNING: at net/ipv4/tcp_input.c:2533 tcp_fastretrans_alert()
> ls21b kernel: [ 7530.354051] Pid: 0, comm: swapper Not tainted 2.6.24-rc5-mm1 #1
> ls21b kernel: [ 7530.389487]
> ls21b kernel: [ 7530.389488] Call Trace:
> ls21b kernel: [ 7530.413030]  <IRQ>  [<ffffffff80482374>] tcp_fastretrans_alert+0x127/0xdaf
> ls21b kernel: [ 7530.454295]  [<ffffffff804850cd>] tcp_ack+0xf2f/0x10fe
> ls21b kernel: [ 7530.485066]  [<ffffffff80488503>] tcp_rcv_established+0x695/0x79a
> ls21b kernel: [ 7530.521542]  [<ffffffff8025c46a>] trace_hardirqs_off+0x39/0xdc
> ls21b kernel: [ 7530.556468]  [<ffffffff8048eb70>] tcp_v4_do_rcv+0x37/0x3e1
> ls21b kernel: [ 7530.589317]  [<ffffffff80491764>] tcp_v4_rcv+0xac7/0xb93
> ls21b kernel: [ 7530.621126]  [<ffffffff80472c40>] ip_local_deliver_finish+0x54/0x20f
> ls21b kernel: [ 7530.659168]  [<ffffffff80472d20>] ip_local_deliver_finish+0x134/0x20f
> ls21b kernel: [ 7530.697724]  [<ffffffff804732cc>] ip_local_deliver+0x72/0x7a
> ls21b kernel: [ 7530.731609]  [<ffffffff80472b7c>] ip_rcv_finish+0x3c0/0x430
> ls21b kernel: [ 7530.764977]  [<ffffffff8044d9a6>] netif_receive_skb+0x10e/0x44d
> ls21b kernel: [ 7530.800422]  [<ffffffff80473223>] ip_rcv+0x326/0x35d
> ls21b kernel: [ 7530.830148]  [<ffffffff8044dc77>] netif_receive_skb+0x3df/0x44d
> ls21b kernel: [ 7530.865603]  [<ffffffff8814d44a>] :bnx2:bnx2_poll+0x1262/0x14a4
> ls21b kernel: [ 7530.901039]  [<ffffffff8034817d>] __next_cpu+0x19/0x28
> ls21b kernel: [ 7530.931805]  [<ffffffff802323a1>] find_busiest_group+0x252/0x6da
> ls21b kernel: [ 7530.967768]  [<ffffffff8025c46a>] trace_hardirqs_off+0x39/0xdc
> ls21b kernel: [ 7531.002693]  [<ffffffff8025c46a>] trace_hardirqs_off+0x39/0xdc
> ls21b kernel: [ 7531.037612]  [<ffffffff8025c21f>] check_chain_key+0x9c/0x15f
> ls21b kernel: [ 7531.071501]  [<ffffffff8026012b>] __lock_acquire+0xdee/0xf06
> ls21b kernel: [ 7531.105386]  [<ffffffff80450476>] net_rx_action+0x75/0x234
> ls21b kernel: [ 7531.138233]  [<ffffffff80450476>] net_rx_action+0x75/0x234
> ls21b kernel: [ 7531.171074]  [<ffffffff804504ed>] net_rx_action+0xec/0x234
> ls21b kernel: [ 7531.203920]  [<ffffffff80243f02>] __do_softirq+0x5f/0xe3
> ls21b kernel: [ 7531.235721]  [<ffffffff8020d5cc>] call_softirq+0x1c/0x28
> ls21b kernel: [ 7531.267528]  [<ffffffff8020ecdf>] do_softirq+0x45/0x108
> ls21b kernel: [ 7531.298811]  [<ffffffff80243ea1>] irq_exit+0x4e/0x50
> ls21b kernel: [ 7531.328540]  [<ffffffff8020ef3d>] do_IRQ+0x171/0x194
> ls21b kernel: [ 7531.358267]  [<ffffffff8020c8c6>] ret_from_intr+0x0/0xf
> ls21b kernel: [ 7531.389549]  <EOI>  [<ffffffff8020b1ec>] default_idle+0x58/0x8a
> ls21b kernel: [ 7531.425096]  [<ffffffff8020b1ea>] default_idle+0x56/0x8a
> ls21b kernel: [ 7531.456900]  [<ffffffff8020b194>] default_idle+0x0/0x8a
> ls21b kernel: [ 7531.488186]  [<ffffffff8020b2d3>] cpu_idle+0xb5/0xec
> ls21b kernel: [ 7531.517913]  [<ffffffff802226f4>] start_secondary+0x3ca/0x3da
> 

That is

	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
		tp->fackets_out = 0;

