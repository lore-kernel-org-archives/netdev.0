From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/9][RFC] KVM virtio_net performance
Date: Mon, 11 Aug 2008 17:51:39 +0800
Message-ID: <E1KSU3v-00037r-00@gondolin.me.apana.org.au>
References: <200808111744.27915.rusty@rustcorp.com.au>
Cc: anthony@codemonkey.ws, netdev@vger.kernel.org, davem@davemloft.net
To: rusty@rustcorp.com.au (Rusty Russell)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50412 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751234AbYHKJvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 05:51:50 -0400
In-Reply-To: <200808111744.27915.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell <rusty@rustcorp.com.au> wrote:
>
> add an "else if (skb->ip_summed == CHECKSUM_PARTIAL)" case...

If you're going to hack the guest kernel, then you might as well
fix the guest DHCP client.  However, we should default checksum
offload to off until we know that the client is capable of handling
it (to handle guests that haven't been fixed).

One easy way of doing this is to hook up the rx checksum offload
option in the guest with the tx offload option in the host.  In
other words, when rx offload is enabled in the guest we enable
tx offload in the host, and disable it vice versa.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
