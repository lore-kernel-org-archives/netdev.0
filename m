From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: avoid BUG_ON() with large packets when
	CONFIG_DEBUG_SG=y
Date: Wed, 31 Mar 2010 12:17:46 +0300
Message-ID: <20100331091746.GB31085@redhat.com>
References: <201003301526.35720.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932976Ab0CaJVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 05:21:23 -0400
Content-Disposition: inline
In-Reply-To: <201003301526.35720.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 03:26:35PM +1030, Rusty Russell wrote:
> AFAICT only weird kvm setups and lguest traverse this code path now.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

vhost still lacks support mergeable buffers so it uses this path.

> ---
>  drivers/net/virtio_net.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -351,6 +351,9 @@ static int add_recvbuf_big(struct virtne
>  	char *p;
>  	int i, err, offset;
>  
> +	/* This is a waste of cycles, but satisfies CONFIG_DEBUG_SG. */
> +	sg_init_table(sg, ARRAY_SIZE(sg));
> +

How about moving sg into virtnet_info? This way we could call
this only once, right?

>  	/* page in sg[MAX_SKB_FRAGS + 1] is list tail */
>  	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
>  		first = get_a_page(vi, gfp);
