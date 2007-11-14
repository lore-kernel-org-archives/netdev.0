From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/24] [NET]: Eliminate duplicate copies of dst_discard
Date: Tue, 13 Nov 2007 21:34:16 -0800 (PST)
Message-ID: <20071113.213416.151969246.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZs-0001GK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37439
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754675AbXKNFeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:34:17 -0500
In-Reply-To: <E1IplZs-0001GK-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:20 +0800

> [NET]: Eliminate duplicate copies of dst_discard
> 
> We have a number of copies of dst_discard scattered around the place which
> all do the same thing, namely free a packet on the input or output paths.
> 
> This patch deletes all of them except dst_discard and points all the users
> to it.
> 
> The only non-trivial bit is decnet where it returns an error.  However,
> conceptually this is identical to the blackhole functions used in IPv4
> and IPv6 which do not return errors.  So they should either all return
> errors or all return zero.  For now I've stuck with the majority and
> picked zero as the return value.
> 
> It doesn't really matter in practice since few if any driver would react
> differently depending on a zero return value or NET_RX_DROP.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
