From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v2 08/16] net: stmmac: Use readl_poll_timeout
Date: Wed, 8 Feb 2017 14:18:09 +0100
Message-ID: <653b51ad-bc37-e32a-daf3-625b15e652d5@st.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
 <20170208083121.27949-9-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-9-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/8/2017 9:31 AM, Corentin Labbe wrote:
> The dwmac_dma_reset function use an open coded of readl_poll_timeout().
> Replace the open coded handling with the proper function.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> index e4cda39..e60bfca 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> @@ -17,6 +17,7 @@
>  *******************************************************************************/
>
>  #include <linux/io.h>
> +#include <linux/iopoll.h>
>  #include "common.h"
>  #include "dwmac_dma.h"
>
> @@ -25,19 +26,16 @@
>  int dwmac_dma_reset(void __iomem *ioaddr)
>  {
>  	u32 value = readl(ioaddr + DMA_BUS_MODE);
> -	int limit;
> +	int err;
>
>  	/* DMA SW reset */
>  	value |= DMA_BUS_MODE_SFT_RESET;
>  	writel(value, ioaddr + DMA_BUS_MODE);
> -	limit = 10;
> -	while (limit--) {
> -		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
> -			break;
> -		mdelay(10);
> -	}
>
> -	if (limit < 0)
> +	err = readl_poll_timeout(ioaddr + DMA_BUS_MODE, value,
> +				 !(value & DMA_BUS_MODE_SFT_RESET),
> +				 100000, 10000);
> +	if (err)
>  		return -EBUSY;
>
>  	return 0;
>
