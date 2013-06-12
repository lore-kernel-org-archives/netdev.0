From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: sh_eth: fix incorrect RX length error if
 R8A7740
Date: Wed, 12 Jun 2013 23:25:15 +0400
Message-ID: <51B8CB1B.9020304@cogentembedded.com>
References: <51B7CFFB.7090801@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <51B7CFFB.7090801@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/12/2013 05:33 AM, Shimoda, Yoshihiro wrote:

> This patch fixes an issue that the driver increments the "RX length error"
> on every buffer in sh_eth_rx() if the R8A7740.
> This patch also adds a description about the Receive Frame Status bits.

> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
>   This patch is based on the latest net-next.git.

>   drivers/net/ethernet/renesas/sh_eth.c |   15 +++++++++++----
>   1 files changed, 11 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 43d8490..ab2f9c2 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1260,16 +1260,23 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status)
>   		desc_status = edmac_to_cpu(mdp, rxdesc->status);
>   		pkt_len = rxdesc->frame_length;
>
> -#if defined(CONFIG_ARCH_R8A7740)
> -		desc_status >>= 16;
> -#endif
> -
>   		if (--boguscnt < 0)
>   			break;
>
>   		if (!(desc_status & RDFEND))
>   			ndev->stats.rx_length_errors++;
>
> +#if defined(CONFIG_ARCH_R8A7740)
> +		/*
> +		 * In case of almost GETHER/ETHERs, the Receive Frame State

    Erm, minor nit: it seems you forgot "all" after "almost". Hence it's 
probably worth resubmitting...

> +		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
> +		 * bit 0. However, in case of the R8A7740's GETHER, the RFS
> +		 * bits are from bit 25 to bit 16. So, the driver needs right
> +		 * shifting by 16.
> +		 */
> +		desc_status >>= 16;
> +#endif
> +

WBR, Sergei

