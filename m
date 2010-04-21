From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] cxgb3: fix linkup issue
Date: Wed, 21 Apr 2010 12:12:14 -0700
Message-ID: <4BCF4E0E.1080805@chelsio.com>
References: <4BCD0424.8030501@ct.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28809 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab0DUTL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:11:59 -0400
In-Reply-To: <4BCD0424.8030501@ct.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> I encountered an issue that not to link up on cxgb3 fabric.
> I bisected and found that this regression was introduced by
> 0f07c4ee8c800923ae7918c231532a9256233eed.
>
> Correct to pass phy_addr to cphy_init() at t3_xaui_direct_phy_prep().
>
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>   

Sorry for the review delay, I just came back from some time off.
Acked-by: Divy Le Ray <divy@chelsio.com>

> ---
>  drivers/net/cxgb3/ael1002.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
> index 5248f9e..35cd367 100644
> --- a/drivers/net/cxgb3/ael1002.c
> +++ b/drivers/net/cxgb3/ael1002.c
> @@ -934,7 +934,7 @@ static struct cphy_ops xaui_direct_ops = {
>  int t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
>  			    int phy_addr, const struct mdio_ops *mdio_ops)
>  {
> -	cphy_init(phy, adapter, MDIO_PRTAD_NONE, &xaui_direct_ops, mdio_ops,
> +	cphy_init(phy, adapter, phy_addr, &xaui_direct_ops, mdio_ops,
>  		  SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_TP,
>  		  "10GBASE-CX4");
>  	return 0;
>   

