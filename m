From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: fix sparse warnings
Date: Tue, 4 Nov 2014 17:35:17 +0100
Message-ID: <54590045.3050305@st.com>
References: <1415035734-24163-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:42770 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751999AbaKDQfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 11:35:31 -0500
In-Reply-To: <1415035734-24163-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/2014 6:28 PM, Andy Shevchenko wrote:
> This patch fixes the following sparse warnings.
>
> drivers/net/ethernet/stmicro/stmmac/enh_desc.c:381:30: warning: symbol 'enh_desc_ops' was not declared. Should it be static?
> drivers/net/ethernet/stmicro/stmmac/norm_desc.c:253:30: warning: symbol 'ndesc_ops' was not declared. Should it be static?
> drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c:141:33: warning: symbol 'stmmac_ptp' was not declared. Should it be static?
>
> There is no functional change.

Hello Andy

I have never seen this kind of warnings. I prefer to not include the
stmmac.h in enh_desc.c and norm_desc.c but eventually to move the
following from stmmac.h to common.h:
   extern const struct stmmac_desc_ops enh_desc_ops;
   extern const struct stmmac_desc_ops ndesc_ops;
what do you think?

peppe


>
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/enh_desc.c        | 2 ++
>   drivers/net/ethernet/stmicro/stmmac/norm_desc.c       | 2 ++
>   drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c | 2 ++
>   3 files changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> index 1e2bcf5..ddd4272 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> @@ -23,8 +23,10 @@
>   *******************************************************************************/
>
>   #include <linux/stmmac.h>
> +
>   #include "common.h"
>   #include "descs_com.h"
> +#include "stmmac.h"
>
>   static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
>   				  struct dma_desc *p, void __iomem *ioaddr)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> index 35ad4f4..46b882c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> @@ -23,8 +23,10 @@
>   *******************************************************************************/
>
>   #include <linux/stmmac.h>
> +
>   #include "common.h"
>   #include "descs_com.h"
> +#include "stmmac.h"
>
>   static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
>   			       struct dma_desc *p, void __iomem *ioaddr)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
> index 76ad214..88e0da3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
> @@ -25,8 +25,10 @@
>
>   #include <linux/io.h>
>   #include <linux/delay.h>
> +
>   #include "common.h"
>   #include "stmmac_ptp.h"
> +#include "stmmac.h"
>
>   static void stmmac_config_hw_tstamping(void __iomem *ioaddr, u32 data)
>   {
>
