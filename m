From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH] amd-xgbe: fix unsigned comparison against less than zero
Date: Tue, 15 Nov 2016 08:09:06 -0600
Message-ID: <9b6547cf-a37e-e7b2-d725-4bccc1fb2dfc@amd.com>
References: <20161115121842.5774-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0061.outbound.protection.outlook.com ([104.47.36.61]:22876
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932756AbcKOOJN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 09:09:13 -0500
In-Reply-To: <20161115121842.5774-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2016 6:18 AM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Comparing unsigned int ret to less than zero for an error status
> check is never true.  Fix this by making ret a signed int. Reduce
> scope of ret too.
> 
> Found with static analysis by CoverityScan, CID 1377750

Thanks Colin, this was already identified by someone else and I
submitted the patch yesterday.

Thanks,
Tom

> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
> index 4ba4332..168507e 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
> @@ -2346,7 +2346,7 @@ static bool xgbe_phy_valid_speed(struct xgbe_prv_data *pdata, int speed)
>  static int xgbe_phy_link_status(struct xgbe_prv_data *pdata, int *an_restart)
>  {
>  	struct xgbe_phy_data *phy_data = pdata->phy_data;
> -	unsigned int ret, reg;
> +	unsigned int reg;
>  
>  	*an_restart = 0;
>  
> @@ -2365,7 +2365,8 @@ static int xgbe_phy_link_status(struct xgbe_prv_data *pdata, int *an_restart)
>  
>  	if (phy_data->phydev) {
>  		/* Check external PHY */
> -		ret = phy_read_status(phy_data->phydev);
> +		int ret = phy_read_status(phy_data->phydev);
> +
>  		if (ret < 0)
>  			return 0;
>  
> 
