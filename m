From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IrDA] irda-usb TX path optimization
Date: Tue, 16 Jan 2007 14:48:13 +1100
Message-ID: <E1H6fIz-0003Ne-00@gondolin.me.apana.org.au>
References: <20070115.193754.59662700.davem@davemloft.net>
Cc: samuel@sortiz.org, avl@logic.at, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3162 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932209AbXAPDsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 22:48:50 -0500
To: davem@davemloft.net (David Miller)
In-Reply-To: <20070115.193754.59662700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> Technically this is a bug fix too because once an SKB hits the
> transmit function it should essentially be immutable, ie. you
> shouldn't be writing to it.  tcpdump sniffers could be looking
> at the SKB, as one example.

We do have a way around that with skb_header_cloned.  In fact
it looks like VLAN should use it as otherwise TCP packets will
get copied unnecessarily.

This is still not optimal for AF_PACKET users since they will
still cause things like VLANs to do the copy even when it isn't
necessary because it doesn't touch any part of the packet that
AF_PACKET actually looks at.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
