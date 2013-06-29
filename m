From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH RFC net-next v1 1/1] net: fec: Fix RMON registers on imx6
Date: Sat, 29 Jun 2013 05:58:40 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE0150D3F5@039-SN2MPN1-023.039d.mgd.msft.net>
References: <Jim Baxter <jim_baxter@mentor.com>
 <1372432075-11629-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Joe Perches <joe@perches.com>, Chris Healy <cphealy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0188.outbound.messaging.microsoft.com ([213.199.154.188]:54965
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751431Ab3F2F6t convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 01:58:49 -0400
In-Reply-To: <1372432075-11629-1-git-send-email-jim_baxter@mentor.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/13 23:08, Jim Baxter wrote:

> commit 38ae92d "fec: Add support for reading RMON registers" causes the imx6Q to crash.
>
> This fixes it and clears it using the MIB Control Register's MIB_CLEAR bit.
>
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index ed6180e..a1f0413 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -607,8 +607,12 @@ fec_restart(struct net_device *ndev, int duplex)  #ifndef CONFIG_M5272
>  	/* Disable, clear, and enable the MIB */
>  	writel(1 << 31, fep->hwp + FEC_MIB_CTRLSTAT);
> -	for (i = RMON_T_DROP; i < IEEE_R_OCTETS_OK; i++)
> -		writel(0, fep->hwp + i);
> +	if (strcmp(id_entry->name, "imx6q-fec") == 0) {
> +		writel(1 << 29, fep->hwp + FEC_MIB_CTRLSTAT);
> +	} else {
> +		for (i = RMON_T_DROP; i < IEEE_R_OCTETS_OK; i++)
> +			writel(0, fep->hwp + i);
> +	}
>  	writel(0, fep->hwp + FEC_MIB_CTRLSTAT);  #endif
>  
> --
> 1.7.10.4

It is not necessary to clear MIB since fec_restart() will reset MAC which cause all MAC register auto reset to  zero.
 
 
Thanks,
Andy
