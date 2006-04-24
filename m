From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Netpoll checksum issue
Date: Mon, 24 Apr 2006 20:22:50 +1000
Message-ID: <20060424102250.GA24437@gondor.apana.org.au>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com> <20060419103153.64ef0054@localhost.localdomain> <6d6a94c50604191854m73b241e3v104d713b7bb93674@mail.gmail.com> <20060423113432.GA16424@gondor.apana.org.au> <6d6a94c50604232242hd091922q8a2a0c78f1163b3c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:21519 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750722AbWDXKW6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 06:22:58 -0400
To: Aubrey <aubreylee@gmail.com>
Content-Disposition: inline
In-Reply-To: <6d6a94c50604232242hd091922q8a2a0c78f1163b3c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2006 at 01:42:12PM +0800, Aubrey wrote:
>
>   dev->last_rx = jiffies;
>   skb->dev = dev;
>   skb->protocol = eth_type_trans(skb, dev);
>   skb->ip_summed = CHECKSUM_UNNECESSARY;
>   netif_rx(skb);

This doesn't make sense.  First of all you're setting ip_summed to
CHECK_UNNECESSARY unconditionally which is most likely wrong.

What's more, if this was the driver that you were using, then
checksum_udp couldn't possibly fail since the first thing it does
is check ip_summed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
