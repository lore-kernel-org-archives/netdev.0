From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: mv643xx_eth: use managed devm_kzalloc
Date: Wed, 10 Apr 2013 22:41:40 +0400
Message-ID: <5165B264.6000605@cogentembedded.com>
References: <1365615483-26318-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365615483-26318-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/10/2013 09:38 PM, Sebastian Hesselbarth wrote:

> This patch moves shared private data kzalloc to managed devm_kzalloc and
> cleans now unneccessary kfree and error handling.
>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Note that there is also an ioremap call, that could be transferred to
> devm_ioremap_resource. But as long as mv643xx_eth and mvmdio iomem
> resources overlap, this will throw -EBUSY.
>
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: Florian Fainelli <florian@openwrt.org>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
>   drivers/net/ethernet/marvell/mv643xx_eth.c |   17 ++++-------------
>   1 file changed, 4 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index bbe6104..955baab 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -2547,25 +2547,22 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
>   	struct mv643xx_eth_shared_private *msp;
>   	const struct mbus_dram_target_info *dram;
>   	struct resource *res;
> -	int ret;
>   
>   	if (!mv643xx_eth_version_printed++)
>   		pr_notice("MV-643xx 10/100/1000 ethernet driver version %s\n",
>   			  mv643xx_eth_driver_version);
>   
> -	ret = -EINVAL;
>   	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>   	if (res == NULL)
> -		goto out;
> +		return -EINVAL;
>   
> -	ret = -ENOMEM;
> -	msp = kzalloc(sizeof(*msp), GFP_KERNEL);
> +	msp = devm_kzalloc(&pdev->dev, sizeof(*msp), GFP_KERNEL);
>   	if (msp == NULL)
> -		goto out;
> +		return -ENOMEM;
>   
>   	msp->base = ioremap(res->start, resource_size(res));
>   	if (msp->base == NULL)
> -		goto out_free;
> +		return -EADDRNOTAVAIL;

    -ENOMEM usually.

WBR, Sergei
