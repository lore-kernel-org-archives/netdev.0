From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC 17/42] drivers/net/ethernet/renesas: don't check resource
 with devm_ioremap_resource
Date: Sun, 12 May 2013 00:35:39 +0400
Message-ID: <518EAB9B.8040106@cogentembedded.com>
References: <1368173847-5661-1-git-send-email-wsa@the-dreams.de> <1368173847-5661-18-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368173847-5661-18-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/10/2013 12:17 PM, Wolfram Sang wrote:

> devm_ioremap_resource does sanity checks on the given resource. No need to
> duplicate this in the driver.
>
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c |   14 +-------------
>   1 file changed, 1 insertion(+), 13 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 33dc6f2..6175839 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2661,14 +2661,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>   	struct sh_eth_private *mdp = NULL;
>   	struct sh_eth_plat_data *pd = pdev->dev.platform_data;
>   
> -	/* get base addr */
> -	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -	if (unlikely(res == NULL)) {
> -		dev_err(&pdev->dev, "invalid resource\n");
> -		ret = -EINVAL;
> -		goto out;
> -	}
> -
>   	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
>   	if (!ndev) {
>   		ret = -ENOMEM;

     There's ndev->base_addr = res->start; below this which you broke. NAK.
You should really compile-test your patches.

WBR, Sergei
