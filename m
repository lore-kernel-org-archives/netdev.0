From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Mon, 10 Sep 2007 08:12:52 -0400
Message-ID: <1189426372.4271.19.camel@localhost>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
	 <20070907035528.GA3755@ludhiana> <46E11C07.50307@katalix.com>
	 <20070908164222.GB3765@ludhiana>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jeff@garzik.org, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: Mandeep Singh Baines <mandeep.baines@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:51063 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932565AbXIJMNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 08:13:01 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1550998wah
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 05:13:00 -0700 (PDT)
In-Reply-To: <20070908164222.GB3765@ludhiana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-08-09 at 09:42 -0700, Mandeep Singh Baines wrote:

> Reading the "interrupt pending" register would require an MMIO read.
> MMIO reads are very expensive. In some systems the latency of an MMIO
> read can be 1000x that of an L1 cache access.

Indeed.

> However, work_done() doesn't have to be inefficient. For newer
> devices you can implement work_done() without an MMIO read by polling
> the next ring entry status in memory or some other mechanism. Since
> PCI is coherent, acceses to this memory location could be cached
> after the first miss. For architectures where PCI is not coherent you'd 
> have to go to memory for every poll. So for these architectures has_work()
> will be moderately expensive (memory access) even when has_work() does
> not require an MMIO read. This might affect home routers: not sure if MIPS or
> ARM have coherent PCI.

I think the effect would be clearly experimentally observable in smaller
devices e.g the Geode you seem to be experimenting on.
One other suggestion i made in the paper is to something along the lines
of cached_irq_mask for the i8259

cheers,
jamal

