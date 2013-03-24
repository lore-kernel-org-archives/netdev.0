From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH v2] bnx2x: fix assignment of signed expression to
 unsigned variable
Date: Sun, 24 Mar 2013 08:00:10 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20BEBB46@SJEXCHMB06.corp.ad.broadcom.com>
References: <1364105425-8198-1-git-send-email-gmate.amit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: "Kumar Amit Mehta" <gmate.amit@gmail.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364105425-8198-1-git-send-email-gmate.amit@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Kumar Amit Mehta
> Sent: Sunday, March 24, 2013 8:10 AM
> To: Eilon Greenstein
> Cc: davem@davemloft.net; dan.carpenter@oracle.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; kernel-
> janitors@vger.kernel.org
> Subject: [PATCH v2] bnx2x: fix assignment of signed expression to unsigned variable
> 
> fix for incorrect assignment of signed expression to unsigned variable.
> 
> Signed-off-by: Kumar Amit Mehta <gmate.amit@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |   18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> index 5682054..91ecd6a 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> @@ -2139,12 +2139,12 @@ static u8 bnx2x_dcbnl_get_cap(struct net_device *netdev, int capid, u8 *cap)
>  			break;
>  		default:
>  			BNX2X_ERR("Non valid capability ID\n");
> -			rval = -EINVAL;
> +			rval = 1;
>  			break;
>  		}
>  	} else {
>  		DP(BNX2X_MSG_DCB, "DCB disabled\n");
> -		rval = -EINVAL;
> +		rval = 1;
>  	}
> 
>  	DP(BNX2X_MSG_DCB, "capid %d:%x\n", capid, *cap);
> @@ -2170,12 +2170,12 @@ static int bnx2x_dcbnl_get_numtcs(struct net_device *netdev, int tcid, u8 *num)
>  			break;
>  		default:
>  			BNX2X_ERR("Non valid TC-ID\n");
> -			rval = -EINVAL;
> +			rval = 1;
>  			break;
>  		}
>  	} else {
>  		DP(BNX2X_MSG_DCB, "DCB disabled\n");
> -		rval = -EINVAL;
> +		rval = 1;
>  	}
> 
>  	return rval;
> @@ -2188,7 +2188,7 @@ static int bnx2x_dcbnl_set_numtcs(struct net_device *netdev, int tcid, u8 num)
>  	return -EINVAL;
>  }
> 
> -static u8  bnx2x_dcbnl_get_pfc_state(struct net_device *netdev)
> +static u8 bnx2x_dcbnl_get_pfc_state(struct net_device *netdev)
>  {
>  	struct bnx2x *bp = netdev_priv(netdev);
>  	DP(BNX2X_MSG_DCB, "state = %d\n", bp->dcbx_local_feat.pfc.enabled);
> @@ -2390,12 +2390,12 @@ static u8 bnx2x_dcbnl_get_featcfg(struct net_device *netdev, int featid,
>  			break;
>  		default:
>  			BNX2X_ERR("Non valid featrue-ID\n");
> -			rval = -EINVAL;
> +			rval = 1;
>  			break;
>  		}
>  	} else {
>  		DP(BNX2X_MSG_DCB, "DCB disabled\n");
> -		rval = -EINVAL;
> +		rval = 1;
>  	}
> 
>  	return rval;
> @@ -2431,12 +2431,12 @@ static u8 bnx2x_dcbnl_set_featcfg(struct net_device *netdev, int featid,
>  			break;
>  		default:
>  			BNX2X_ERR("Non valid featrue-ID\n");
> -			rval = -EINVAL;
> +			rval = 1;
>  			break;
>  		}
>  	} else {
>  		DP(BNX2X_MSG_DCB, "dcbnl call not valid\n");
> -		rval = -EINVAL;
> +		rval = 1;
>  	}
> 
>  	return rval;
> --
> 1.7.9.5

Kumar,  thanks!

Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
