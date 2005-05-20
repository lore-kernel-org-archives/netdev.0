From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Super TSO
Date: Thu, 19 May 2005 17:55:42 -0700 (PDT)
Message-ID: <20050519.175542.07642115.davem@davemloft.net>
References: <20050519.172107.59468102.davem@davemloft.net>
	<200505200036.j4K0aVVG008391@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: leonid.grossman@neterion.com
In-Reply-To: <200505200036.j4K0aVVG008391@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Leonid Grossman" <leonid.grossman@neterion.com>
Date: Thu, 19 May 2005 17:36:25 -0700

> > > One likely scenario where this feature is desirable is a 
> > system with 
> > > highly fragmented memory.
> > > In this case, the number of physical fragments per TSO 
> > frame could be 
> > > always so high that it will be cheaper (on a given 
> > platform) to copy 
> > > the frame than to DMA it.
> > 
> > We always chop up the user data into individual system pages 
> > when we build TSO frames, so I can't see how any kind of 
> > memory fragmentation could be an issue.
> 
> This is exactly what I wanted to hear :-)
> If the TSO implementation guarantees that the payload comes (for the most
> part) 
> in physically continuous pages, then the number of fragments 
> will never get out of whack, and my argument indeed becomes invalid.

You misunderstand me.  The TCP segmenter splits the incoming
user data into page size'd chunks.  So a 64K packet uses
64K / PAGE_SIZE individual pages.

The only thing the driver author needs to be aware of wrt. this
is to never wake up the TX netif queue until at least
"MAX_SKB_FRAGS + 1" transmit descriptors are available.

You'll see that every driver setting NETIF_F_SG implements
this test.

> Sure. On the other hand, the TCP code is unaware of the copy vs. DMA
> costs on a particular NIC (well, this is actually more specific to a
> system than to a NIC).  But I guess as long as both the packet size
> and the number of fragments will not get very big at the same time,
> A NIC will be OK.

They can and will be as large as "MAX_SKB_FRAGS + 1".
