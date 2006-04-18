From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Wed, 19 Apr 2006 08:08:24 +1000
Message-ID: <20060418220824.GA11374@gondor.apana.org.au>
References: <20060417171253.4e988afc@localhost.localdomain> <E1FVk6q-0000Tf-00@gondolin.me.apana.org.au> <20060418.145416.114278524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15117 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750753AbWDRWIi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 18:08:38 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060418.145416.114278524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2006 at 02:54:16PM -0700, David S. Miller wrote:
> 
> There are other areas of the packet which are interpreted in various
> ways.  For example, the martian source handling will dump the MAC
> directly from skb->mac.raw into the kernel logs.

That's scary.  I think this stuff needs an audit.

> The output path is so much cleaner, because things like the protocol
> are filled out in the struct flowi so there is no need to be parsing
> the SKB in any way.

Absolutely.  I think we should put Stephen's patch in ASAP.  Once the
immediate problem is gone we can take our time and make the input path
more like the output.

At the end of this I'd like to see the skb argument from ip_route_input
replaced by a dst_entry.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
