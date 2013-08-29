From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch v2] net/fec: cleanup types in fec_get_mac()
Date: Thu, 29 Aug 2013 19:48:58 +0100
Message-ID: <1377802138.5372.12.camel@bwh-desktop.uk.level5networks.com>
References: <20130829082514.GB14334@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fabio Estevam" <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130829082514.GB14334@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-29 at 11:25 +0300, Dan Carpenter wrote:
> My static checker complains that on some arches unsigned longs can be 8
> characters which is larger than the buffer is only 6 chars.
> Additionally, Ben Hutchings points out that the buffer actually holds
> big endian data and the buffer we are reading from is CPU endian.

It's not really as clear-cut as that. :-)  But I think it's slightly
more logical this way.

> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
> v2: fix endian annotations and reverse the beXX_to_cpu() calls so that
>     they say cpu_to_beXX().
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index fdf9307..0b12866 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1100,10 +1100,10 @@ static void fec_get_mac(struct net_device *ndev)
>  	 * 4) FEC mac registers set by bootloader
>  	 */
>  	if (!is_valid_ether_addr(iap)) {
> -		*((unsigned long *) &tmpaddr[0]) =
> -			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
> -		*((unsigned short *) &tmpaddr[4]) =
> -			be16_to_cpu(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
> +		*((__be32 *) &tmpaddr[0]) =
> +			cpu_to_be32(readl(fep->hwp + FEC_ADDR_LOW));
> +		*((__be16 *) &tmpaddr[4]) =
> +			cpu_to_be16(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
>  		iap = &tmpaddr[0];
>  	}
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

