From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH] bnx2:Make various functions to have a return type of
 void in the file bnx2.c
Date: Fri, 10 Jul 2015 03:20:56 +0000
Message-ID: <0EA5B226BC5C7B45A71BF612AA8A019E01947ACBF7@AVMB1.qlogic.org>
References: <1436380260-19221-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:33355 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751293AbbGJDVC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 23:21:02 -0400
In-Reply-To: <1436380260-19221-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Nicholas Krause [mailto:xerofoify@gmail.com]
> Sent: Wednesday, July 08, 2015 11:31 AM
> To: Sony Chacko
> Cc: Dept-GE Linux NIC Dev; netdev; linux-kernel
> Subject: [PATCH] bnx2:Make various functions to have a return
> type of void in the file bnx2.c
> 
> This makes various functions that never fail nor signal their caller
> with a error code when a failure occurs to now have a return
> type of void for the file bnx2.c.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c
> b/drivers/net/ethernet/broadcom/bnx2.c
> index 2b66ef3..ddf0ccc 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -1087,7 +1087,7 @@ bnx2_resolve_flow_ctrl(struct bnx2
> *bp)
>  	}
>  }
> 
> -static int
> +static void
>  bnx2_5709s_linkup(struct bnx2 *bp)
>  {
>  	u32 val, speed;
> @@ -1101,7 +1101,7 @@ bnx2_5709s_linkup(struct bnx2 *bp)
>  	if ((bp->autoneg & AUTONEG_SPEED) == 0) {
>  		bp->line_speed = bp->req_line_speed;
>  		bp->duplex = bp->req_duplex;
> -		return 0;
> +		return;
>  	}
>  	speed = val & MII_BNX2_GP_TOP_AN_SPEED_MSK;
>  	switch (speed) {
> @@ -1123,10 +1123,9 @@ bnx2_5709s_linkup(struct bnx2 *bp)
>  		bp->duplex = DUPLEX_FULL;
>  	else
>  		bp->duplex = DUPLEX_HALF;
> -	return 0;
>  }
> 
> -static int
> +static void
>  bnx2_5708s_linkup(struct bnx2 *bp)
>  {
>  	u32 val;
> @@ -1152,10 +1151,9 @@ bnx2_5708s_linkup(struct bnx2 *bp)
>  	else
>  		bp->duplex = DUPLEX_HALF;
> 
> -	return 0;
>  }
> 
> -static int
> +static void
>  bnx2_5706s_linkup(struct bnx2 *bp)
>  {
>  	u32 bmcr, local_adv, remote_adv, common; @@ -1172,7
> +1170,7 @@ bnx2_5706s_linkup(struct bnx2 *bp)
>  	}
> 
>  	if (!(bmcr & BMCR_ANENABLE)) {
> -		return 0;
> +		return;
>  	}
> 
>  	bnx2_read_phy(bp, bp->mii_adv, &local_adv); @@ -1188,11
> +1186,9 @@ bnx2_5706s_linkup(struct bnx2 *bp)
>  			bp->duplex = DUPLEX_HALF;
>  		}
>  	}
> -
> -	return 0;
>  }
> 
> -static int
> +static void
>  bnx2_copper_linkup(struct bnx2 *bp)
>  {
>  	u32 bmcr;
> @@ -1264,8 +1260,6 @@ bnx2_copper_linkup(struct bnx2 *bp)
>  		if (ext_status & EXT_STATUS_MDIX)
>  			bp->phy_flags |= BNX2_PHY_FLAG_MDIX;
>  	}
> -
> -	return 0;
>  }
> 
>  static void
> --
> 2.1.4

Acked-by: Sony Chacko <sony.chacko@qlogic.com>

Thanks,
Sony
