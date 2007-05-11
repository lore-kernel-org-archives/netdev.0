From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 11:37:07 +0530
Message-ID: <OF0B685C71.DE1952AA-ON652572D8.001FCC16-652572D8.00219C94@in.ibm.com>
References: <20070510.135707.10298706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	rick.jones2@hp.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:35035 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642AbXEKGIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 02:08:05 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B69hao7954652
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:09:43 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B6BBl2163904
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:11:21 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B67Zkg022011
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:07:36 +1000
In-Reply-To: <20070510.135707.10298706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller <davem@davemloft.net> wrote on 05/11/2007 02:27:07 AM:

> > I don't understand how transmitting already batched up packets in one
go
> > introduce latency.
>
> Keep thinking :-)
>
> The only case where these ideas can be seriously considered is during
> netif_wake_queue().  In all other cases we go straight to the device
> from sendmsg(), since there is space in the TX ring, and we should
> not try to batch as that will add latency.

I am not very clear about this, you are saying latency will increase
due to old packets not being cache-warm ?

But the existing code will do exactly the same thing as what I am
proposing, except it will iterate over all the packets one by one.
So will batching them make latency worse ?

In the sendmsg case you wrote above (is it tcp_transmit_skb), it will
still come via IP (through dst_output) ?

I would like to try your idea if you are sure it will reduce latency.

Thanks,

- KK

> So maybe find a solution in that area, some new driver interface that
> can suck N packets out of a qdisc when netif_wake_queue() occurs.
>
> If you look at the contexts in which netif_wake_queue() is called,
> it's perfect, it already has the TX state of the driver locked, it has
> the TX descriptor head/tail pointers handy, etc. and it's already
> taken all the cache misses needed in order to work with this state.

