From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Thu, 15 Nov 2007 09:11:10 +0800
Message-ID: <20071115011110.GB21193@gondor.apana.org.au>
References: <200711140927.39796.nickpiggin@yahoo.com.au> <20071114.031022.183117678.davem@davemloft.net> <20071114114844.GA13927@gondor.apana.org.au> <20071114.154616.46285694.davem@davemloft.net> <Pine.LNX.4.64.0711141650150.21965@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nickpiggin@yahoo.com.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4384 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755461AbXKOBLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 20:11:18 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711141650150.21965@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 05:03:25PM -0800, Christoph Lameter wrote:
> 
> Well this is likely the result of the SLUB regression. If you allocate an 
> order 1 page then the zone locks need to be taken. SLAB queues the a 
> couple of higher order pages and can so serve a couple of requests without 
> going into the page allocator whereas SLUB has to go directly to the page 
> allocator for allocate and free. I guess that needs fixing in the page 
> allocator. Or do I need to add a mechanism to buffer higher order page 
> allcoations to SLUB?

Actually this serves to discourage people from using high-order
allocations which IMHO is a good thing :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
