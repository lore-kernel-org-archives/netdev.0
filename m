From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: skb allocation from interrupt handler?
Date: Thu, 10 Aug 2017 00:29:19 +0200
Message-ID: <20170809222919.GA4101@electric-eye.fr.zoreil.com>
References: <598A3890.80705@ti.com>
 <20170808.160022.550877862496200067.davem@davemloft.net>
 <598B3A14.5020507@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38896 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752358AbdHIW31 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 18:29:27 -0400
Content-Disposition: inline
In-Reply-To: <598B3A14.5020507@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Murali Karicheri <m-karicheri2@ti.com> :
[...]
> The internal memory or FIFO can store only up to 3 MTU sized packets. So that has to
> be processed before PRU gets another packets to send to CPU. So per above, 
> it is not ideal to run NAPI for this scenario, right? Also for NetCP we use
> about 128 descriptors with MTU size buffers to handle 1Gbps Ethernet link.
> Based on that roughly we would need at least 10-12 buffers in the FIFO.
> 
> Currently we have a NAPI implementation in use that gives throughput of 95Mbps for
> MTU sized packets, but our UDP iperf tests shows less than 1% packet loss for an
> offered traffic of 95Mbps with MTU sized packets.  This is not good for industrial
> network using HSR/PRP protocol for network redundancy. We need to have zero packet
> loss for MTU sized packets at 95Mbps throughput. That is the problem description.

Imvho you should instrument the kernel to figure where the excess latency that
prevents NAPI processing to take place within 125 us of physical packet reception
comes from.

> As an experiment, I have moved the packet processing to irq handler to see if we 
> can take advantage of CPU cycle to processing the packet instead of NAPI
> and to check if the firmware encounters buffer overflow. The result is positive 
> with no buffer overflow seen at the firmware and no packet loss in the iperf test.
> But we want to do more testing as an experiment and ran into a uart console locks
> up after running traffic for about 2 minutes. So I tried enabling the DEBUG HACK 
> options to get some clue on what is happening and ran into the trace I shared 
> earlier. So what function can I use to allocate SKB from interrupt handler ?

Is your design also so tight on memory that you can't even refill your own
software skb pool from some non-irq context then only swap buffers in the
irq handler ?

-- 
Ueimor
