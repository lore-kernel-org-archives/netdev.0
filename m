From: Andi Kleen <ak@muc.de>
Subject: Re: Intel and TOE in the news
Date: Sat, 19 Feb 2005 21:27:31 +0100
Message-ID: <m1psywb8i4.fsf@muc.de>
References: <4216B62D.6000502@pobox.com>
	<20050219041007.GA17896@xi.wantstofly.org>
	<20050219114624.373af63f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050219114624.373af63f.davem@davemloft.net> (David S.
 Miller's message of "Sat, 19 Feb 2005 11:46:24 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

> Read what they are doing.  The idea is not to have all of this network
> protocol logic off-cpu, the idea is to "reduce some of the time
> a processor typically spends waiting for memory to feed back information"
>
> Think about what part of the network I/O equation that is working on.
> It's not protocol offload, that's for sure.

<speculating freely>

It would be nice if the NIC could asynchronously trigger prefetches in
the CPU. Currently a lot of the packet processing cost goes
to waiting for read cache misses.

E.g. 

- NIC receives packet. 
- Tells target CPU to prefetch RX descriptor and headers. 
- CPU later looks at them and doesn't have to wait a for a cache miss.

Drawback is that you would need to tell the NIC in advance
on which CPU you want to process the packet, but with Linux
IRQ affinity that's easy to figure out. 

-Andi
