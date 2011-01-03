From: hayeswang <hayeswang@realtek.com>
Subject: RE: [net-next-2.6 04/08] r8169: 8168DP specific MII registers access methods.
Date: Mon, 3 Jan 2011 20:30:02 +0800
Message-ID: <2BC582F01DD74ABE849496523D21F085@realtek.com.tw>
References: <20110102233704.GE5780@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'Ben Hutchings' <benh@debian.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtitmf2.realtek.com.tw ([60.250.210.236]:3271 "EHLO
	mf2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab1ACMaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 07:30:05 -0500
In-Reply-To: <20110102233704.GE5780@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Monday, January 03, 2011 7:37 AM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; Hayeswang; Ben Hutchings
> Subject: [net-next-2.6 04/08] r8169: 8168DP specific MII 
> registers access methods.
> 
> Adapted from version 8.019.00 of Realtek's r8168 driver.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes <hayeswang@realtek.com>
> ---
>  drivers/net/r8169.c |   83 
> +++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 81 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c index 
> f9d8ff0..7f6fd12 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -277,6 +277,20 @@ enum rtl8168_8101_registers {
>  #define	EFUSEAR_DATA_MASK		0xff
>  };
>  
> +enum rtl8168_registers {
> +	EPHY_RXER_NUM		= 0x7c,
> +	OCPDR			= 0xb0,	/* OCP GPHY access */
> +#define OCPDR_WRITE_CMD			0x80000000
> +#define OCPDR_READ_CMD			0x00000000
> +#define OCPDR_REG_MASK			0xff
> +#define OCPDR_GPHY_REG_SHIFT		12

The source code of realtek makes a mistake. The value of OCPDR_GPHY_REG_SHIFT
must be 16, not 12. The reg should be at bit 16 ~ 22.

> +#define OCPDR_DATA_MASK			0xffff
> +	OCPAR			= 0xb4,
> +#define OCPAR_FLAG			0x80000000
> +#define OCPAR_GPHY_WRITE_CMD		0x8000f060
> +#define OCPAR_GPHY_READ_CMD		0x0000f060
> +};
> +

