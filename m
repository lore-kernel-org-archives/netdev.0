From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: Fix host panic if ioctl called with wrong index
Date: Tue, 25 May 2010 11:13:40 +0300
Message-ID: <20100525081339.GB13593@redhat.com>
References: <20100525054036.2022.66692.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab0EYIRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 04:17:53 -0400
Content-Disposition: inline
In-Reply-To: <20100525054036.2022.66692.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 11:10:36AM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Missed a boundary value check in vhost_set_vring. The host panics if
> idx == nvqs is used in ioctl commands in vhost_virtqueue_init.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Thanks, applied.

> ---
>  drivers/vhost/vhost.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -ruNp org/drivers/vhost/vhost.c new/drivers/vhost/vhost.c
> --- org/drivers/vhost/vhost.c	2010-05-24 09:25:57.000000000 +0530
> +++ new/drivers/vhost/vhost.c	2010-05-24 09:26:53.000000000 +0530
> @@ -374,7 +374,7 @@ static long vhost_set_vring(struct vhost
>  	r = get_user(idx, idxp);
>  	if (r < 0)
>  		return r;
> -	if (idx > d->nvqs)
> +	if (idx >= d->nvqs)
>  		return -ENOBUFS;
>  
>  	vq = d->vqs + idx;
