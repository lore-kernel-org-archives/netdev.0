From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] virtio_net: Fix skb->csum_start computation
Date: Tue, 10 Jun 2008 18:21:42 -0400
Message-ID: <484EFE76.1080309@garzik.org>
References: <200806082049.00641.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38972 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756135AbYFJWVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:21:45 -0400
In-Reply-To: <200806082049.00641.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> From: Mark McLoughlin <markmc@redhat.com>
> 
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
> 
> (Without this patch, GSO packets from a guest to the world outside the
> host are corrupted).
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/net/virtio_net.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)

applied 1-4


