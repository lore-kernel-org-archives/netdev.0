From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [patch -next] bnx2x: unlock before returning an error
Date: Wed, 25 Jan 2012 10:14:54 +0200
Message-ID: <1327479294.11041.3.camel@lb-tlvb-dmitry>
References: <20120125075931.GA20199@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4838 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab2AYIOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 03:14:47 -0500
In-Reply-To: <20120125075931.GA20199@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-01-25 at 10:59 +0300, Dan Carpenter wrote:
> We introduced a new return here but forgot to drop the lock.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> index cb6339c..69465c3 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> @@ -1836,6 +1836,7 @@ static int bnx2x_vlan_mac_del_all(struct bnx2x *bp,
>  			rc = exeq->remove(bp, exeq->owner, exeq_pos);
>  			if (rc) {
>  				BNX2X_ERR("Failed to remove command\n");
> +				spin_unlock_bh(&exeq->lock);
>  				return rc;
>  			}
>  			list_del(&exeq_pos->link);
> --

Thank you, Dan.

Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
