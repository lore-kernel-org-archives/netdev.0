From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
	in transport mode
Date: Mon, 22 Jun 2009 17:07:31 +0800
Message-ID: <20090622090731.GA22496@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christophe Saout <christophe@saout.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56918 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751660AbZFVJHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 05:07:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 06:04:56AM -0000, Christophe Saout wrote:
>
> I have a working (but possibly inelegant version), which I am proposing.
> I know there are obvious things that can be improved, but I'm just
> posting it here for discussion.  Also, I'm not sure my skb handling is
> fully correct.

This patch isn't quite right.  You're wiping out the existing
checksum without verifying it at all.  Now you could argue that
IPsec would guarantee the checksum to be correct anyway.  However
this is not always the case.  Somebody might be trying something
clever like using transport mode in conjunction with NAT prior
to IPsec which means that the packet may have traversed hops
prior to it being protected by IPsec.

The correct solution is to use the encap nat_oa field to adjust
the checksum.  That's why that field exists.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
