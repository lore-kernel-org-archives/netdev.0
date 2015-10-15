From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: corretly check failed allocation
Date: Thu, 15 Oct 2015 17:44:05 +0100
Message-ID: <1444927445.1607.113.camel@citrix.com>
References: <1444926376-29211-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <taesoo@gatech.edu>, <yeongjin.jang@gatech.edu>, <insu@gatech.edu>
To: Insu Yun <wuninsu@gmail.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444926376-29211-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-10-15 at 12:26 -0400, Insu Yun wrote:
> Since vzalloc can be failed in memory pressure,
> return value should be checked and return ENOMEM.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>
> ---
>  drivers/net/xen-netback/xenbus.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen
> -netback/xenbus.c
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

Please fix the coding style, perhaps using checkpatch.pl or by observing
the surrounding code.

Ian.

> +
>  	be->vif->num_queues = requested_num_queues;
>  	be->vif->stalled_queues = requested_num_queues;
>  
