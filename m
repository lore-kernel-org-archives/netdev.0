From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net] hyperv: Fix the NETIF_F_SG flag setting in netvsc
Date: Wed, 17 Jul 2013 11:40:41 +0000
Message-ID: <8906250c5dfc4f7ab0d84019bf7b9a44@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1374040880-20468-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374040880-20468-1-git-send-email-haiyangz@microsoft.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Haiyang Zhang [mailto:haiyangz@microsoft.com]
> Sent: Wednesday, July 17, 2013 2:01 AM
> To: davem@davemloft.net; netdev@vger.kernel.org
> Cc: Haiyang Zhang; KY Srinivasan; olaf@aepfle.de; jasowang@redhat.com; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org
> Subject: [PATCH net] hyperv: Fix the NETIF_F_SG flag setting in netvsc
> 
> SG mode is not currently supported by netvsc, so remove this flag for now.
> Otherwise, it will be unconditionally enabled by commit ec5f0615642
>     "Kill link between CSUM and SG features"
> Previously, the SG feature is disabled because CSUM is not set here.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

We would need to apply this patch to 3.9 and 3.10 as well that are currently broken.

K. Y
> ---
>  drivers/net/hyperv/netvsc_drv.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 4dccead..23a0fff 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -431,8 +431,8 @@ static int netvsc_probe(struct hv_device *dev,
>  	net->netdev_ops = &device_ops;
> 
>  	/* TODO: Add GSO and Checksum offload */
> -	net->hw_features = NETIF_F_SG;
> -	net->features = NETIF_F_SG | NETIF_F_HW_VLAN_CTAG_TX;
> +	net->hw_features = 0;
> +	net->features = NETIF_F_HW_VLAN_CTAG_TX;
> 
>  	SET_ETHTOOL_OPS(net, &ethtool_ops);
>  	SET_NETDEV_DEV(net, &dev->device);
> --
> 1.7.4.1
> 
> 
