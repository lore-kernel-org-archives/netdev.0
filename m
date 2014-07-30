From: Dinh Nguyen <dinguyen@altera.com>
Subject: Re: [PATCH net v3 6/6] net: stmmac: squelch sparse warning with
 casts
Date: Wed, 30 Jul 2014 09:52:45 -0500
Message-ID: <1406731965.23841.2.camel@linux-builds1>
References: <1406671607-27368-1-git-send-email-vbridgers2013@gmail.com>
	 <1406671607-27368-7-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<peppe.cavallaro@st.com>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>, <linux@arm.linux.org.uk>,
	<linux-arm-kernel@lists.infradead.org>, <robh+dt@kernel.org>,
	<davem@davemloft.net>, <vbridger@altera.com>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0140.outbound.protection.outlook.com ([207.46.163.140]:2460
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753348AbaG3Ozt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 10:55:49 -0400
In-Reply-To: <1406671607-27368-7-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vince,

On Tue, 2014-07-29 at 17:06 -0500, Vince Bridgers wrote:
> Add casts to squelch the following sparse warnings so we can see
> the ones that matter when they occur.
> 
> stmmac_platform.c:260:20: warning: incorrect type in argument 1
> 			  (different address spaces)
> stmmac_platform.c:260:20:    expected void const *static extern
> 			  [signed] [long] [typedef] [tls] inline [safe] ptr
> stmmac_platform.c:260:20:    got void [noderef] <asn:2>*[assigned] addr
> stmmac_platform.c:261:32: warning: incorrect type in argument 1
> 			  (different address spaces)
> stmmac_platform.c:261:32:    expected void const *static extern
> 			  [signed] [long] [typedef] [tls] inline [safe] ptr
> stmmac_platform.c:261:32:    got void [noderef] <asn:2>*[assigned] addr
> 


I think you should update your sparse. I have 0.5.0 and the only sparse
warnings for stmmac are:

drivers/net/ethernet/stmicro/stmmac/enh_desc.c:381:30: warning: symbol
'enh_desc_ops' was not declared. Should it be static?
drivers/net/ethernet/stmicro/stmmac/norm_desc.c:253:30: warning: symbol
'ndesc_ops' was not declared. Should it be static?
drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:128:29: warning:
symbol 'socfpga_gmac_data' was not declared. Should it be static?
drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c:141:33: warning:
symbol 'stmmac_ptp' was not declared. Should it be static?


Dinh
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V3: Add minor sparse warning correction as part of series
> V2: Not present in prior submissions
> ---
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index bb524a9..228003b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -257,8 +257,8 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>  
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	addr = devm_ioremap_resource(dev, res);
> -	if (IS_ERR(addr))
> -		return PTR_ERR(addr);
> +	if (IS_ERR((void __force *)addr))
> +		return PTR_ERR((void __force *)addr);
>  
>  	plat_dat = dev_get_platdata(&pdev->dev);
>  	if (pdev->dev.of_node) {
