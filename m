From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] virtio: use kcalloc and kmalloc_array
Date: Tue, 26 Jul 2016 19:34:51 +0300
Message-ID: <20160726193359-mutt-send-email-mst@kernel.org>
References: <20160726162008.310530368@networkplumber.org>
 <20160726162037.897138759@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485AbcGZQez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 12:34:55 -0400
Content-Disposition: inline
In-Reply-To: <20160726162037.897138759@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2016 at 09:20:11AM -0700, Stephen Hemminger wrote:
> Preferred style is to use kcalloc and kmalloc_array.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> --- a/drivers/net/virtio_net.c	2016-07-26 09:13:19.805400983 -0700
> +++ b/drivers/net/virtio_net.c	2016-07-26 09:13:19.801400965 -0700
> @@ -1551,13 +1551,13 @@ static int virtnet_find_vqs(struct virtn
>  		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
>  
>  	/* Allocate space for find_vqs parameters */
> -	vqs = kzalloc(total_vqs * sizeof(*vqs), GFP_KERNEL);
> +	vqs = kzalloc(total_vqs, sizeof(*vqs), GFP_KERNEL);

Does this  build? kzalloc seems to take only two arguments ... what
am I missing?


>  	if (!vqs)
>  		goto err_vq;
> -	callbacks = kmalloc(total_vqs * sizeof(*callbacks), GFP_KERNEL);
> +	callbacks = kmalloc_array(total_vqs, sizeof(*callbacks), GFP_KERNEL);
>  	if (!callbacks)
>  		goto err_callback;
> -	names = kmalloc(total_vqs * sizeof(*names), GFP_KERNEL);
> +	names = kmalloc_array(total_vqs, sizeof(*names), GFP_KERNEL);
>  	if (!names)
>  		goto err_names;
>  
> @@ -1613,10 +1613,10 @@ static int virtnet_alloc_queues(struct v
>  {
>  	int i;
>  
> -	vi->sq = kzalloc(sizeof(*vi->sq) * vi->max_queue_pairs, GFP_KERNEL);
> +	vi->sq = kcalloc(vi->max_queue_pairs, sizeof(*vi->sq), GFP_KERNEL);
>  	if (!vi->sq)
>  		goto err_sq;
> -	vi->rq = kzalloc(sizeof(*vi->rq) * vi->max_queue_pairs, GFP_KERNEL);
> +	vi->rq = kcalloc(vi->max_queue_pairs, sizeof(*vi->rq), GFP_KERNEL);
>  	if (!vi->rq)
>  		goto err_rq;
>  
