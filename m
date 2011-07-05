From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 09:08:09 -0700 (PDT)
Message-ID: <20110705.090809.1320878912859271524.davem@davemloft.net>
References: <4E12B5A6.2020802@inliniac.net>
	<1309849214.2720.45.camel@edumazet-laptop>
	<D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, victor@inliniac.net, netdev@vger.kernel.org
To: Chetan.Loke@netscout.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146Ab1GEQIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:08:24 -0400
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Date: Tue, 5 Jul 2011 12:03:29 -0400

> Can we not do something like:
> 
> a = src_ip_addr;
> b = dst_ip_addr;
> 
> if (ip_is_fragment(ip_hdr(skb)))
> 	c = ip_hdr->id;
> else
> 	c = src_port | dest_port ; /* port_32 etc - Similar to what we have today 

A UDP flow can be composed of fragmented and non-fragmented
parts, we want all of the packets from that flow to land
on the same hash.

Your scheme does not provide that essential property.
