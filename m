From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 01/14] tg3: Fix 5906 link problems
Date: Tue, 3 Mar 2009 12:17:39 -0800
Message-ID: <20090303201739.GD21611@xw6200.broadcom.net>
References: <1235616367.15995@xw6200>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3854 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915AbZCCUSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 15:18:24 -0500
In-Reply-To: <1235616367.15995@xw6200>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David.  Can we also apply this patch into net-2.6?  It fixes a
regression that was introduced during the 2.6.29 development cycle.

On Wed, Feb 25, 2009 at 04:21:20PM -0800, Matt Carlson wrote:
> Commit 6833c043f9fc03696fde623914c4a0277df2a0bc introduced the phy
> auto-powerdown capability.  While the APD feature only works for 5761
> and 5784 asic revisions, the (harmless portion of the) code was applied
> to all 5705 and newer devices.  However, the 5906 phy departs from the
> usual design.  This commit was interfering with the 5906's ability to
> negotiate link against some switches.  This patch corrects the problem.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/tg3.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 67630fb..c7bbbb1 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -1473,7 +1473,8 @@ static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
>  {
>  	u32 reg;
>  
> -	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
> +	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
> +	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
>  		return;
>  
>  	reg = MII_TG3_MISC_SHDW_WREN |
> -- 
> 1.6.0.6
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

