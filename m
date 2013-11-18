From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] vhost: remove the dead branch
Date: Mon, 18 Nov 2013 12:16:17 +0200
Message-ID: <20131118101617.GB3559@redhat.com>
References: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194Ab3KRKNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 05:13:10 -0500
Content-Disposition: inline
In-Reply-To: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 11:19:21AM +0800, Zhi Yong Wu wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> Since vhost_dev_init() forever return 0, some branches are never run,
> therefore need to be removed.
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/vhost/net.c  |    5 -----
>  drivers/vhost/scsi.c |    5 -----
>  drivers/vhost/test.c |    5 -----
>  3 files changed, 0 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 831eb4f..0554785 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -707,11 +707,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
>  		n->vqs[i].sock_hlen = 0;
>  	}
>  	r = vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
> -	if (r < 0) {
> -		kfree(n);
> -		kfree(vqs);
> -		return r;
> -	}
>  
>  	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
>  	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index e663921..9d5e18d 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -1421,14 +1421,9 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
>  
>  	tcm_vhost_init_inflight(vs, NULL);
>  
> -	if (r < 0)
> -		goto err_init;
> -
>  	f->private_data = vs;
>  	return 0;
>  
> -err_init:
> -	kfree(vqs);
>  err_vqs:
>  	vhost_scsi_free(vs);
>  err_vs:
> diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
> index 339eae8..99cb960 100644
> --- a/drivers/vhost/test.c
> +++ b/drivers/vhost/test.c
> @@ -118,11 +118,6 @@ static int vhost_test_open(struct inode *inode, struct file *f)
>  	vqs[VHOST_TEST_VQ] = &n->vqs[VHOST_TEST_VQ];
>  	n->vqs[VHOST_TEST_VQ].handle_kick = handle_vq_kick;
>  	r = vhost_dev_init(dev, vqs, VHOST_TEST_VQ_MAX);
> -	if (r < 0) {
> -		kfree(vqs);
> -		kfree(n);
> -		return r;
> -	}
>  
>  	f->private_data = n;
>  
> -- 
> 1.7.6.5
