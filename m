From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need
 also be handled by UFO
Date: Wed, 02 Oct 2013 03:41:28 -0700
Message-ID: <1380710488.19002.67.camel@edumazet-glaptop.roam.corp.google.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
	 <20130930114343.GA6356@minipsycho.brq.redhat.com>
	 <20130930172312.GE10771@order.stressinduktion.org>
	 <20131001105837.GA1424@minipsycho.brq.redhat.com>
	 <20131001120907.GH10771@order.stressinduktion.org>
	 <20131001123214.GI10771@order.stressinduktion.org>
	 <20131001214721.GJ10771@order.stressinduktion.org>
	 <20131001232534.GM10771@order.stressinduktion.org>
	 <20131002085842.GA1528@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:63305 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644Ab3JBKs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 06:48:56 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so860732pab.22
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 03:48:56 -0700 (PDT)
In-Reply-To: <20131002085842.GA1528@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 10:58 +0200, Jiri Pirko wrote:
> Wed, Oct 02, 2013 at 01:25:34AM CEST, hannes@stressinduktion.org wrote:
> >-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
> >+	if (((length > mtu) || (skb && skb_has_frags(skb))) &&

> 
> This seems correct to me. sk_is_gso would work as well is you apply my
> patch "[patch net] ip6_output: do skb ufo init for peeked non ufo skb as
> well" which does the setting of gso_size.

Well, skb having frags or not should not be a concern :
Thats an allocation choice (lets say to avoid high order allocations). 

Setting gso_size is probably better.
