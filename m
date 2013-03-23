From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] bnx2x: fix assignment of signed expression to unsigned
 variable
Date: Sat, 23 Mar 2013 22:56:47 +0300
Message-ID: <20130323195454.GB9138@mwanda>
References: <1364064775-19319-1-git-send-email-gmate.amit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Kumar Amit Mehta <gmate.amit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38120 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779Ab3CWT5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 15:57:06 -0400
Content-Disposition: inline
In-Reply-To: <1364064775-19319-1-git-send-email-gmate.amit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 23, 2013 at 11:52:55AM -0700, Kumar Amit Mehta wrote:
> fix for incorrect assignment of signed expression to unsigned variable.
> 

This fix isn't right.

> Signed-off-by: Kumar Amit Mehta <gmate.amit@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |   20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> index 5682054..b90533a 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> @@ -2139,12 +2139,12 @@ static u8 bnx2x_dcbnl_get_cap(struct net_device *netdev, int capid, u8 *cap)
>  			break;
>  		default:
>  			BNX2X_ERR("Non valid capability ID\n");
> -			rval = -EINVAL;
> +			rval = EINVAL;
>  			break;
>  		}
>  	} else {
>  		DP(BNX2X_MSG_DCB, "DCB disabled\n");
> -		rval = -EINVAL;
> +		rval = EINVAL;

This function is called from dcbnl_getcap().  It returns zero on
success, but it's not clear what it should return on failure.  But
certainly it's not a positive EINVAL.

>  	}
>  
>  	DP(BNX2X_MSG_DCB, "capid %d:%x\n", capid, *cap);
> @@ -2154,7 +2154,7 @@ static u8 bnx2x_dcbnl_get_cap(struct net_device *netdev, int capid, u8 *cap)
>  static int bnx2x_dcbnl_get_numtcs(struct net_device *netdev, int tcid, u8 *num)
>  {
>  	struct bnx2x *bp = netdev_priv(netdev);
> -	u8 rval = 0;
> +	s8 rval = 0;

Just use "int" here.

>  
>  	DP(BNX2X_MSG_DCB, "tcid %d\n", tcid);
>  
> @@ -2188,7 +2188,7 @@ static int bnx2x_dcbnl_set_numtcs(struct net_device *netdev, int tcid, u8 num)
>  	return -EINVAL;
>  }
>  
> -static u8  bnx2x_dcbnl_get_pfc_state(struct net_device *netdev)
> +static u8 bnx2x_dcbnl_get_pfc_state(struct net_device *netdev)
>  {
>  	struct bnx2x *bp = netdev_priv(netdev);
>  	DP(BNX2X_MSG_DCB, "state = %d\n", bp->dcbx_local_feat.pfc.enabled);
> @@ -2282,7 +2282,7 @@ static int bnx2x_set_admin_app_up(struct bnx2x *bp, u8 idtype, u16 idval, u8 up)
>  	else {
>  		/* app table is full */
>  		BNX2X_ERR("Application table is too large\n");
> -		return -EBUSY;
> +		return EBUSY;
>  	}

The fix for this is more involved.  The function prototype should
be changed to return an int.  The caller should be updated to check
for errors.

Etc.

regards,
dan carpenter
