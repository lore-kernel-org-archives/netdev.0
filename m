From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next] sh_eth: add support for r8a7790 SoC
Date: Fri, 10 May 2013 15:00:00 +0400
Message-ID: <518CD330.5030009@cogentembedded.com>
References: <1368172891-26381-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1368172891-26381-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10-05-2013 12:01, Simon Horman wrote:

> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
[...]

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 33dc6f2..1ec26bd 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -342,7 +343,8 @@ static void sh_eth_select_mii(struct net_device *ndev)
>   #endif
>
>   /* There is CPU dependent code */
> -#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
> +#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779) || \
> +	defined(CONFIG_ARCH_R8A7790)
>   #define SH_ETH_RESET_DEFAULT	1
>   static void sh_eth_set_duplex(struct net_device *ndev)
>   {
> @@ -370,7 +372,7 @@ static void sh_eth_set_rate(struct net_device *ndev)
>   	}
>   }
>
> -/* R8A7778/9 */
> +/* R8A7778, R8A7779, R8A7790 */
>   static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>   	.set_duplex	= sh_eth_set_duplex,
>   	.set_rate	= sh_eth_set_rate,
> @@ -1275,6 +1277,10 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
>   	if (ret)
>   		goto out;
>
> +#if defined(CONFIG_ARCH_R8A7790)
> +	sh_eth_write(ndev, 0x1, RMIIMODE);
> +#endif
> +

    Ugh, this #ifdef will be hard to get rid of. Perhaps you should add 
a field to 'struct sh_eth_cpu_data' indicating the presence of this 
register instead.

WBR, Sergei

