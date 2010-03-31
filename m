From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 21:53:31 +0800
Message-ID: <20100331135331.GB14082@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-5-git-send-email-timo.teras@iki.fi> <20100331110345.GC12845@gondor.apana.org.au> <1270040773.26743.12.camel@bigi> <20100331131131.GA13793@gondor.apana.org.au> <1270042092.26743.26.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:53486 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933421Ab0CaNxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:53:46 -0400
Content-Disposition: inline
In-Reply-To: <1270042092.26743.26.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 09:28:12AM -0400, jamal wrote:
> 
> -sudo ip route add 192.168.11.100 dev eth0 table 15
> generates an event
> -sudo ip route flush table 15
> generates an event
> -sudo ip route flush table 15
> No event

That's completely different.  We don't have a route flush event,
instead we're sending route delete events.  That's why when the
table is empty you get no events.

If we had a route flush event then it would behave exactly the
same.

BTW you've also made xfrm_state_flush inconsistent with respect
to xfrm_policy_flush.

Dave, please revert this patch.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
