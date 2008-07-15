From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/5] virtio net: Allow receiving SG packets
Date: Tue, 15 Jul 2008 11:52:09 +0800
Message-ID: <20080715035209.GB2657@gondor.apana.org.au>
References: <200807151341.39337.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34865 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752430AbYGODwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:52:21 -0400
Content-Disposition: inline
In-Reply-To: <200807151341.39337.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 10:41:38PM -0500, Rusty Russell wrote:
>
> +	/* If we can receive ANY GSO packets, we must allocate large ones. */
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4)
> +	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)
> +	    || virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
> +		dev->features |= NETIF_F_LRO;

We don't want to do this because LRO implies joining packets
together in an irreversible way which is not what this is about.

Case in point we're now disabling LRO for devices that are
forwarding packets which is totally unnecessary for virtio.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
