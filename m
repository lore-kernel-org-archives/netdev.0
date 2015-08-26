From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, net-next] r8169:Correct value on r810x_phy_power_up
 function
Date: Wed, 26 Aug 2015 10:41:29 -0700 (PDT)
Message-ID: <20150826.104129.894959895104249315.davem@davemloft.net>
References: <1440591370-24649-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbbHZRlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 13:41:32 -0400
In-Reply-To: <1440591370-24649-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <corcodel.marian@gmail.com>
Date: Wed, 26 Aug 2015 15:16:10 +0300

> Correct value on r810x_phy_power_up function normal clean 
>  bit BMCR_PDOWN
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index d6d39df..91cf3a6 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4669,7 +4669,7 @@ static void r810x_phy_power_down(struct rtl8169_private *tp)
>  static void r810x_phy_power_up(struct rtl8169_private *tp)
>  {
>  	rtl_writephy(tp, 0x1f, 0x0000);
> -	rtl_writephy(tp, MII_BMCR, BMCR_ANENABLE);
> +	rtl_writephy(tp, MII_BMCR, ~BMCR_PDOWN);

This DOES NOT only clear BMCR_PDOWN, it sets every other bit in the
register as well.
