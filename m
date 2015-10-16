From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: corretly check failed allocation
Date: Thu, 15 Oct 2015 23:32:18 -0700 (PDT)
Message-ID: <20151015.233218.1351681066787454091.davem@davemloft.net>
References: <1444926376-29211-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444926376-29211-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Thu, 15 Oct 2015 12:26:16 -0400

> Since vzalloc can be failed in memory pressure,
> return value should be checked and return ENOMEM.
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

This is definitely not indented correctly.
