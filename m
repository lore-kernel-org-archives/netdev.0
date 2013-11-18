From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] vhost: fix the wrong log descriptions
Date: Mon, 18 Nov 2013 12:18:33 +0200
Message-ID: <20131118101833.GD3559@redhat.com>
References: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
 <1384744763-7476-3-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288Ab3KRKPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 05:15:31 -0500
Content-Disposition: inline
In-Reply-To: <1384744763-7476-3-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 11:19:23AM +0800, Zhi Yong Wu wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

This one does not make sense to me.
Heads in avail ring are heads which according to Guest are available by
definition.


> ---
>  drivers/vhost/vhost.c  |    2 +-
>  drivers/vhost/vringh.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 78987e4..568d20f 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1241,7 +1241,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  
>  	/* If their number is silly, that's an error. */
>  	if (unlikely(head >= vq->num)) {
> -		vq_err(vq, "Guest says index %u > %u is available",
> +		vq_err(vq, "Guest says index %u > %u is unavailable",
>  		       head, vq->num);
>  		return -EINVAL;
>  	}
> diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
> index 5174eba..86ef6c4 100644
> --- a/drivers/vhost/vringh.c
> +++ b/drivers/vhost/vringh.c
> @@ -57,7 +57,7 @@ static inline int __vringh_get_head(const struct vringh *vrh,
>  	}
>  
>  	if (head >= vrh->vring.num) {
> -		vringh_bad("Guest says index %u > %u is available",
> +		vringh_bad("Guest says index %u > %u is unavailable",
>  			   head, vrh->vring.num);
>  		return -EINVAL;
>  	}
> -- 
> 1.7.6.5
