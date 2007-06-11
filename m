From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] [IPV4]: Add default config support after inetdev_init
Date: Mon, 11 Jun 2007 22:31:11 +1000
Message-ID: <20070611123111.GA20615@gondor.apana.org.au>
References: <20070605062929.GA12024@gondor.apana.org.au> <E1HvSZL-0003AB-00@gondolin.me.apana.org.au> <466D3F92.7050803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4504 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751345AbXFKMb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:31:28 -0400
Content-Disposition: inline
In-Reply-To: <466D3F92.7050803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 11, 2007 at 02:26:58PM +0200, Patrick McHardy wrote:
> 
> I noticed a few more side-effects from the original change that
> seem to be undesired. Some code assumes that dev->ip_ptr != NULL
> implies existance of IP addresses on the device. For example
> fib_check_nh used to allow to add routes to devices only when a
> in_device is present. We can now add routes without having any
> IP addresses configured, which makes routing choose 0.0.0.0 as
> source and invalidates the assumption of some other code that
> the outgoing device of a packet always has an in_device present
> (like MASQUERADE). fib_sync_up used to skip a nexthop when no
> IP addresses was present on the device, now it will keep it.
> There's probably more, I guess we need to audit all in_dev_get
> calls.

Good catch.  I'll work through them.  Oh yeah I still need to do
the same thing for IPv6 too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
