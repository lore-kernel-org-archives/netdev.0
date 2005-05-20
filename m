From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH] Super TSO
Date: Thu, 19 May 2005 18:25:35 -0700
Message-ID: <200505200125.j4K1PaVG015780@guinness.s2io.com>
References: <20050519.175542.07642115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S.Miller'" <davem@davemloft.net>
In-Reply-To: <20050519.175542.07642115.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > > We always chop up the user data into individual system 
> pages when we 
> > > build TSO frames, so I can't see how any kind of memory 
> > > fragmentation could be an issue.
> > 
> > This is exactly what I wanted to hear :-) If the TSO implementation 
> > guarantees that the payload comes (for the most
> > part)
> > in physically continuous pages, then the number of fragments will 
> > never get out of whack, and my argument indeed becomes invalid.
> 
> You misunderstand me.  The TCP segmenter splits the incoming 
> user data into page size'd chunks.  So a 64K packet uses 64K 
> / PAGE_SIZE individual pages.


Yes, I think I'm actually with you. As long as each page is physically
continuous 
and therefore requires one descriptor per page, the total number of
descriptors per packet 
will be only 64K / PAGE_SIZE (plus some for headers), and this is fully
manageable from a NIC prospective.

> 
> The only thing the driver author needs to be aware of wrt. 
> this is to never wake up the TX netif queue until at least 
> "MAX_SKB_FRAGS + 1" transmit descriptors are available.
> 
> You'll see that every driver setting NETIF_F_SG implements this test.
> 
> > Sure. On the other hand, the TCP code is unaware of the 
> copy vs. DMA 
> > costs on a particular NIC (well, this is actually more 
> specific to a 
> > system than to a NIC).  But I guess as long as both the packet size 
> > and the number of fragments will not get very big at the 
> same time, A 
> > NIC will be OK.
> 
> They can and will be as large as "MAX_SKB_FRAGS + 1".
> 
> 
