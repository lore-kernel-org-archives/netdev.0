From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm: UFO + ESP = double fragmentation
Date: Sat, 30 Jan 2016 12:21:02 +0800
Message-ID: <20160130042102.GA22809@gondor.apana.org.au>
References: <20160129234424.GC7907@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49836 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbcA3EVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 23:21:17 -0500
Content-Disposition: inline
In-Reply-To: <20160129234424.GC7907@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2016 at 12:44:24AM +0100, Jiri Bohac wrote:
>
> Is there a situation when xfrm_output_gso() does the right thing?

Yes because you've just broken TSO over IPsec.

In fact you're remarkably close to the right solution which is
to avoid xfrm_output_gso for SKB_GSO_UDP packets.

You should also work through all the other types (e.g., tunnels)
one-by-one and determine which ones should be fragmented and
which ones shouldn't.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
