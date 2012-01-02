From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] xfrm: Call IP receive handler directly for
	inbound tunnel-mode packets
Date: Mon, 2 Jan 2012 18:28:28 +1100
Message-ID: <20120102072828.GA5380@gondor.apana.org.au>
References: <1325475154-15997-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56380 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372Ab2ABH2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 02:28:31 -0500
Content-Disposition: inline
In-Reply-To: <1325475154-15997-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 01, 2012 at 10:32:34PM -0500, David Ward wrote:
> For IPsec tunnel mode (or BEET mode), after inbound packets are xfrm'ed,
> call the IPv4/IPv6 receive handler directly instead of calling netif_rx.
> In addition to avoiding unneeded re-processing of the MAC layer, packets
> will not be received a second time on network taps. (Note that outbound
> packets are only received on network taps post-xfrm, but inbound packets
> were being received both pre- and post-xfrm. So now network taps will
> receive packets in either direction only once, in the form that they go
> "over the wire".)
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

You can't do this as this may cause stack overruns if we nest
too deeply.

Changing the existing tap processing behaviour will also break
existing setups.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
