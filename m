From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: why some packets lost during transmission?
Date: Wed, 15 Jul 2009 19:17:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907151911390.29305@tyr.diku.dk>
References: <A353FA76-7D71-425F-BD67-FEE6DC26EF6F@cs.uni-bonn.de>
 <60230E21F17E384C9BF0B9C98D9E3FDC04B4D3D8@sgp-sg-mb02.sgp.agilent.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: jon_zhou@agilent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:48382 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755232AbZGORSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2009 13:18:40 -0400
In-Reply-To: <60230E21F17E384C9BF0B9C98D9E3FDC04B4D3D8@sgp-sg-mb02.sgp.agilent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 15 Jul 2009, jon_zhou@agilent.com wrote:

> I try to send packets like this:
>
> for (i=0;i<loop;i++)
> {
>    dev->hard_start_xmit(my_skb,dev);
> }
>
> the 'dev' point to network device.
>
> but too many packets lost if the 'loop' is big(i.e. 5000), I suspect the 
> tx buffer of the NIC is full,but the driver does not print any related 
> info.

Hint, look at the return value... it returns NETDEV_TX_OK if its okay.

> how does the upper layer(i.e.arp,qdisc) handle this situation?


Have you looked at pktgen?

Doc:
   Documentation/networking/pktgen.txt

Code:
   net/core/pktgen.c

Look at function pktgen_xmit() and notice that in the latest kernels 
the dev->hard_start_xmit function pointer has been changed to 
dev->netdev_ops->ndo_start_xmit.


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
