From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: sky2: hw checksum failures
Date: Tue, 05 Sep 2006 10:36:43 +1000
Message-ID: <1157416603.22705.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54191 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1751492AbWIEAg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 20:36:58 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen !

So I now have the driver working with the patches I gave you. However,
when I set it up with a 100bT link and transfer a huge file from another
machine (about 10MB/sec throughput), I get a few of these in dmesg

eth2: hw csum failure.
Call Trace:
[C00000000FFEF8D0] [C00000000000F460] .show_stack+0x6c/0x1a0
(unreliable)
[C00000000FFEF970] [C000000000365E48] .netdev_rx_csum_fault+0x4c/0x68
[C00000000FFEFA00] [C000000000362DB8] .__skb_checksum_complete+0x60/0x90
[C00000000FFEFA90] [C0000000003A8A48] .tcp_v4_rcv+0x1a0/0xc18
[C00000000FFEFB60] [C000000000386A54] .ip_local_deliver+0x20c/0x33c
[C00000000FFEFBF0] [C0000000003870D0] .ip_rcv+0x54c/0x5c0
[C00000000FFEFC90] [C000000000369E8C] .netif_receive_skb+0x2a8/0x2e8
[C00000000FFEFD30] [D00000000010E99C] .sky2_poll+0x6e8/0x9dc [sky2]
[C00000000FFEFE40] [C00000000036696C] .net_rx_action+0xb4/0x1b8
[C00000000FFEFEF0] [C000000000048404] .__do_softirq+0xa8/0x168
[C00000000FFEFF90] [C00000000001E3F8] .call_do_softirq+0x14/0x24
[C00000000FFAB9F0] [C00000000000C1F0] .do_softirq+0x78/0xa0
[C00000000FFABA80] [C000000000047F9C] .irq_exit+0x5c/0x74
[C00000000FFABB00] [C00000000000C154] .do_IRQ+0x160/0x184
[C00000000FFABB90] [C0000000000041EC] hardware_interrupt_entry+0xc/0x10
--- Exception: 501 at .cpu_idle+0xd4/0x12c

In fact, the dmesg trace is interesting:

benh@grosgo:~/kernels/linux-work$ dmesg | grep failure
eth2: hw csum failure.
eth2: hw csum failure.
eth2: hw csum failure.
eth2: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
eth2: hw csum failure.
eth2: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.
<unknown>: hw csum failure.

(That's what I get for about 600MB transfered).

The other side is a sungem, I haven't yet had a chance to test with
something else, in case it's actually a problem there, though.

Any idea ? I'll do some tests with some other chips at the other end
(will try 1000bT too) later.

Cheers,
Ben.


