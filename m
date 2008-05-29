From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/3] virtio_net: Fix skb->csum_start computation
Date: Thu, 29 May 2008 17:31:16 +1000
Message-ID: <200805291731.17131.rusty@rustcorp.com.au>
References: <1211887247-31979-1-git-send-email-markmc@redhat.com> <1211887247-31979-3-git-send-email-markmc@redhat.com> <1211887247-31979-4-git-send-email-markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55281 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbYE2Hdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 03:33:52 -0400
In-Reply-To: <1211887247-31979-4-git-send-email-markmc@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 May 2008 21:20:47 Mark McLoughlin wrote:
> hdr->csum_start is the offset from the start of the ethernet
> header to the transport layer checksum field. skb->csum_start
> is the offset from skb->head.
>
> skb_partial_csum_set() assumes that skb->data points to the
> ethernet header - i.e. it computes skb->csum_start by adding
> the headroom to hdr->csum_start.
>
> Since eth_type_trans() skb_pull()s the ethernet header,
> skb_partial_csum_set() should be called before
> eth_type_trans().

As should the rx_bytes += skb->len.  Thanks for this!

Applied (and 1/3, the typo patch).

I'll backport this to -stable, as well.

Thanks,
Rusty.
