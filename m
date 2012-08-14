From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 5/5] net/hyperv: Call netif_carrier_off() after
 register_netdev()
Date: Tue, 14 Aug 2012 15:32:34 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DDFD867@TK5EX14MBXC223.redmond.corp.microsoft.com>
References: <1344940135-17079-1-git-send-email-shchepetkov@ispras.ru>
 <1344940135-17079-6-git-send-email-shchepetkov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ldv-project@ispras.ru" <ldv-project@ispras.ru>
To: Ilya Shchepetkov <shchepetkov@ispras.ru>,
	KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344940135-17079-6-git-send-email-shchepetkov@ispras.ru>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Ilya Shchepetkov [mailto:shchepetkov@ispras.ru]
> Sent: Tuesday, August 14, 2012 6:29 AM
> To: KY Srinivasan
> Cc: Ilya Shchepetkov; Haiyang Zhang; David S. Miller;
> devel@linuxdriverproject.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; ldv-project@ispras.ru
> Subject: [PATCH 5/5] net/hyperv: Call netif_carrier_off() after
> register_netdev()
> 
> For carrier detection to work properly when binding the driver with a
> cable unplugged, netif_carrier_off() should be called after
> register_netdev(), not before.
> 
> Calling netif_carrier_off() before register_netdev() was causing the
> network interface to miss a linkwatch pending event leading to an
> inconsistent state if the link is not up when interface is initialized.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Ilya Shchepetkov <shchepetkov@ispras.ru>
> ---
>  drivers/net/hyperv/netvsc_drv.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> index 8c5a1c4..5734ad0 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -416,9 +416,6 @@ static int netvsc_probe(struct hv_device *dev,
>  	if (!net)
>  		return -ENOMEM;
> 
> -	/* Set initial state */
> -	netif_carrier_off(net);
> -
>  	net_device_ctx = netdev_priv(net);
>  	net_device_ctx->device_ctx = dev;
>  	hv_set_drvdata(dev, net);
> @@ -441,6 +438,9 @@ static int netvsc_probe(struct hv_device *dev,
>  		goto out;
>  	}
> 
> +	/* Set initial state */
> +	netif_carrier_off(net);
> +
>  	/* Notify the netvsc driver of the new device */
>  	device_info.ring_size = ring_size;
>  	ret = rndis_filter_device_add(dev, &device_info);

Thanks.

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
