From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression
 with tbench
Date: Wed, 14 Nov 2007 15:46:16 -0800 (PST)
Message-ID: <20071114.154616.46285694.davem@davemloft.net>
References: <200711140927.39796.nickpiggin@yahoo.com.au>
	<20071114.031022.183117678.davem@davemloft.net>
	<20071114114844.GA13927@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nickpiggin@yahoo.com.au, clameter@sgi.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35207
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755413AbXKNXqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 18:46:17 -0500
In-Reply-To: <20071114114844.GA13927@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Nov 2007 19:48:44 +0800

> [TCP]: Fix size calculation in sk_stream_alloc_pskb
> 
> We round up the header size in sk_stream_alloc_pskb so that
> TSO packets get zero tail room.  Unfortunately this rounding
> up is not coordinated with the select_size() function used by
> TCP to calculate the second parameter of sk_stream_alloc_pskb.
> 
> As a result, we may allocate more than a page of data in the
> non-TSO case when exactly one page is desired.
> 
> In fact, rounding up the head room is detrimental in the non-TSO
> case because it makes memory that would otherwise be available to
> the payload head room.  TSO doesn't need this either, all it wants
> is the guarantee that there is no tail room.
> 
> So this patch fixes this by adjusting the skb_reserve call so that
> exactly the requested amount (which all callers have calculated in
> a precise way) is made available as tail room.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and I'll queue it up for -stable too.
