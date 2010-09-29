From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 16:11:58 +0900
Message-ID: <20100929071158.GA4684@gondor.apana.org.au>
References: <20100928084139.GA26793@gondor.apana.org.au> <1285663738.2607.30.camel@edumazet-laptop> <1285733911.22570.20.camel@edumazet-laptop> <1285734295.22570.25.camel@edumazet-laptop> <20100929043642.GA3660@gondor.apana.org.au> <1285741443.22570.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44179 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403Ab0I2HMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 03:12:05 -0400
Content-Disposition: inline
In-Reply-To: <1285741443.22570.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 29, 2010 at 08:24:03AM +0200, Eric Dumazet wrote:
.
> Well, sometimes people wants to :
> 
> /etc/modprobe.conf
> install ipv6 /bin/true
> 
> 
> Yet, be able to load ip_gre as a module
> 
> so IPV6=m, GRE=m,

I think if we cared about this we should provide ways to disable
IPv6 (if there aren't any already) even when the module is loaded
or the code is built-in.

BTW, I think the code isn't 100% safe as is as it tries to access
skb_dst unconditionally in the IPv6 case.  If the packet came via
a remote source (e.g., bridging and virt) it may not have an IPv6
skb_dst at all.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
