From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: can we reuse an skb
Date: Sat, 20 Jun 2009 12:51:27 +0100
Message-ID: <1245498687.12125.24.camel@deadeye>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com>
	 <4A3BC326.4090203@hp.com> <20090619.162957.156347025.davem@davemloft.net>
	 <1f808b4a0906192054k6182ac2fh1618f0e630033518@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	radhamohan_ch@yahoo.com, netdev@vger.kernel.org
To: Peter Chacko <peterchacko35@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54509 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751232AbZFTLvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 07:51:33 -0400
In-Reply-To: <1f808b4a0906192054k6182ac2fh1618f0e630033518@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-06-20 at 09:24 +0530, Peter Chacko wrote:
> But if a network application is holding on to a NIC-drive level pooled
> buffers,  we also have architectural issues in violating layered
> software design. Application plays at a stateful protocol level, while
> driver should be stateless and flow-unaware.

Meanwhile, in the real world, we want to avoid copying data, so an skb
doesn't belong to any specific protocol layer.

> Another thought in the lines of radha's original idea:
> 
> Assume that we have n-cores capable of processing packet at the same
> time. if we trade off memory for computing, why don't we pre-allocate
> "n" dedicated skb buffers regardless of the size of each packet, but
> just as big as the size of the MTU itself.(forget JUMBO packet for
> now).

MTU is interface-specific, and the MTU tells us whether jumbos are
allowed or not.

Anyway, where is this pre-allocation to be done?

> (  today, dev_alloc_skb() allocate based on the packet len, which
> is memory usage optimized.).
[...]

skbs for received packets are normally allocated in advance anyway,
which means they are already MTU-sized.  However, LRO or GRO can make it
worthwhile to defer skb allocation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
