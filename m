From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
	in transport mode
Date: Tue, 30 Jun 2009 15:00:36 +0800
Message-ID: <20090630070036.GA16225@gondor.apana.org.au>
References: <20090622090731.GA22496@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christophe Saout <christophe@saout.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45792 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751571AbZF3HAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 03:00:39 -0400
Content-Disposition: inline
In-Reply-To: <20090622090731.GA22496@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 05:07:31PM +0800, Herbert Xu wrote:
>
> The correct solution is to use the encap nat_oa field to adjust
> the checksum.  That's why that field exists.

Alas the IKEv2 people still haven't got their acts together so
this is currently only possible with IKEv1.

So I think we should offer both options (plus the option of doing
nothing as we do now).  The default should be to do nothing, as
recomputing the checksum carries some risk which we should make
explicit to the admin by requiring them to turn the option on.

Now as to the technical problem of how to recompute the checksums
cleanly, may I draw your attention to gso_send_checksum which does
exactly what you want.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
