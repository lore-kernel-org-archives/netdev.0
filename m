From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] skbuff:  don't corrupt mac_header on skb expansion
Date: Sun, 5 Jul 2009 11:55:21 +0800
Message-ID: <20090705035521.GA7693@gondor.apana.org.au>
References: <20090617151734.5ce02459@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@ghostprotocols.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60806 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753727AbZGEDz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 23:55:26 -0400
Content-Disposition: inline
In-Reply-To: <20090617151734.5ce02459@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:
> The skb mac_header field is sometimes NULL (or ~0u) as a sentinel
> value. The places where skb is expanded add an offset which would
> change this flag into an invalid pointer (or offset).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

What uses skb_mac_header_was_set apart from a debugging printk
in route.c and nfnetlink_log (which is also essentially a debugging
printk)?

This seems to be a bit much just to make a couple printks work?

What about using mac_len instead to figure out whether the MAC
header is there?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
