From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] gro: Add page frag support
Date: Sun, 04 Jan 2009 16:13:53 -0800 (PST)
Message-ID: <20090104.161353.255048732.davem@davemloft.net>
References: <20081230100705.GA31741@gondor.apana.org.au>
	<20081230100819.GA31787@gondor.apana.org.au>
	<20090102042011.GA20920@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58653
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751923AbZAEANu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 19:13:50 -0500
In-Reply-To: <20090102042011.GA20920@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 2 Jan 2009 15:20:11 +1100

> Here's an updated version with a redundant blank line removed.
> 
> gro: Add page frag support
> 
> This patch allows GRO to merge page frags (skb_shinfo(skb)->frags)
> in one skb, rather than using the less efficient frag_list.
> 
> It also adds a new interface, napi_gro_frags to allow drivers
> to inject page frags directly into the stack without allocating
> an skb.  This is intended to be the GRO equivalent for LRO's
> lro_receive_frags interface.
> 
> The existing GSO interface can already handle page frags with
> or without an appended frag_list so nothing needs to be changed
> there.
> 
> The merging itself is rather simple.  We store any new frag entries
> after the last existing entry, without checking whether the first
> new entry can be merged with the last existing entry.  Making this
> check would actually be easy but since no existing driver can
> produce contiguous frags anyway it would just be mental masturbation.
> 
> If the total number of entries would exceed the capacity of a
> single skb, we simply resort to using frag_list as we do now.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks Herbert.
