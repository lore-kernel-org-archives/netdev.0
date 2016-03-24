From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] stmmac: Fix phy without MDIO subnode
Date: Thu, 24 Mar 2016 16:00:23 +0300
Message-ID: <56F3E4E7.6020608@cogentembedded.com>
References: <1458817012-14293-1-git-send-email-john@metanate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Keeping <john@metanate.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:34542 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757196AbcCXNA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 09:00:26 -0400
Received: by mail-lb0-f170.google.com with SMTP id k12so29742481lbb.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 06:00:25 -0700 (PDT)
In-Reply-To: <1458817012-14293-1-git-send-email-john@metanate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/24/2016 1:56 PM, John Keeping wrote:

> Since commit 88f8b1bb41c6 ("stmmac: Fix 'eth0: No PHY found'
> regression") we no longer allocate mdio_bus_data unless there is a MDIO
> subnode.  This breaks the ethernet on the Radxa Rock2 (using
> rk3288-rock2-square.dts) which does not have an MDIO subnode.
>
> That commit was correct that the phy_bus_name test is unhelpful since we
> allocate "plat" in the same function and never set phy_bus_name so let's
> just drop the test which restores the previous behaviour.
>
> Fixes: 88f8b1bb41c6 ("stmmac: Fix 'eth0: No PHY found' regression")
> Signed-off-by: John Keeping <john@metanate.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index dcbd2a1..e0fa060 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -189,7 +189,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>   	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) == 0)
>   		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
>
> -	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || !plat->mdio_node)
> +	if ((plat->phy_node && !of_phy_is_fixed_link(np)))

    Too many parens...

MBR, Sergei
