From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] IP_MAX_MTU value
Date: Fri, 21 Dec 2012 11:59:10 -0800 (PST)
Message-ID: <20121221.115910.1536088448298730991.davem@davemloft.net>
References: <1356072468.21834.4805.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hp.com, kuznet@ms2.inr.ac.ru
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab2LUT7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 14:59:11 -0500
In-Reply-To: <1356072468.21834.4805.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Thu, 20 Dec 2012 22:47:48 -0800

> We have the following definition in net/ipv4/route.c
> 
> #define IP_MAX_MTU   0xFFF0
> 
> This means that "netperf -t UDP_STREAM", using UDP messages of 65507
> bytes, are fragmented on loopback interface (while its MTU is now 65536
> and should allow those UDP messages being sent without fragments)
> 
> I guess Rick chose 65507 bytes in netperf because it was related to the
> max IPv4 datagram length :
> 
> 65507 + 28 = 65535
> 
> Changing IP_MAX_MTU from 0xFFF0 to 0x10000 seems safe [1], but I might
> miss something really obvious ?
> 
> It might be because in old days we reserved 16 bytes for the ethernet
> header, and we wanted to avoid kmalloc() round-up to kmalloc-131072
> slab ?
> 
> If so, we certainly can limit skb->head to 32 or 64 KB and complete with
> page fragments the remaining space.

I don't think it has to do with kmalloc() at all.

Maybe something strange to do with the fact that each frag has to
be an 8-byte multiple, or something like that?

Alexey choose this value back in 1998, maybe he remembers the
reason for the strange value.

Alexey?
