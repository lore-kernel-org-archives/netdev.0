From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: corretly check failed allocation
Date: Thu, 15 Oct 2015 18:13:02 +0100
Message-ID: <20151015171301.GB5541@zion.uk.xensource.com>
References: <1444926376-29211-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <taesoo@gatech.edu>,
	<yeongjin.jang@gatech.edu>, <insu@gatech.edu>
To: Insu Yun <wuninsu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444926376-29211-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 15, 2015 at 12:26:16PM -0400, Insu Yun wrote:
> Since vzalloc can be failed in memory pressure,
> return value should be checked and return ENOMEM.

This function doesn't return ENOMEM, instead it writes to xenstore to
indicate error. The commit log needs to be updated.

> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>
> ---
>  drivers/net/xen-netback/xenbus.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 929a6e7..e288246 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -788,6 +788,11 @@ static void connect(struct backend_info *be)
>  	/* Use the number of queues requested by the frontend */
>  	be->vif->queues = vzalloc(requested_num_queues *
>  				  sizeof(struct xenvif_queue));
> +  if (!be->vif->queues)  {
> +    xenbus_dev_fatal(dev, -ENOMEM, "allocating queues");
> +    return;
> +  }
> +

The indentation is wrong. Please configure your email client properly.

And please use "goto err" for error handling -- yes, I understand there
is existing code that returns directly but IMHO that should be fixed
too.

We.

>  	be->vif->num_queues = requested_num_queues;
>  	be->vif->stalled_queues = requested_num_queues;
>  
> -- 
> 1.9.1
