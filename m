From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 6 Feb 2009 19:09:24 +1100
Message-ID: <20090206080924.GA6062@gondor.apana.org.au>
References: <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090205.235258.257422341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, zbr@ioremap.net, w@1wt.eu, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49767 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752462AbZBFIKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 03:10:01 -0500
Content-Disposition: inline
In-Reply-To: <20090205.235258.257422341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 11:52:58PM -0800, David Miller wrote:
>
> In fact we can optimize that even further in many ways, for example by
> dropping the skb->data backed memory once the skb is queued to the
> socket receive buffer.  That will make skb->data buffer lifetimes
> miniscule even under heavy receive load.

Indeed, while I was doing the tun accounting stuff and reviewing
the rx accounting users, it was apparent that we don't need to
carry most of this stuff in our receive queues.

This is almost the opposite of the skbless data idea for TSO.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
