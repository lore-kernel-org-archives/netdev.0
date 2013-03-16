From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net] bnx2x: add missing napi deletion in error path
Date: Sat, 16 Mar 2013 08:18:35 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20BE36EA@SJEXCHMB06.corp.ad.broadcom.com>
References: <1363361274-25754-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Merav Sicron" <meravs@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4879 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552Ab3CPISl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 04:18:41 -0400
In-Reply-To: <1363361274-25754-1-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Michal Schmidt [mailto:mschmidt@redhat.com]
> Sent: Friday, March 15, 2013 5:28 PM
> To: netdev@vger.kernel.org
> Cc: Merav Sicron; Eilon Greenstein; Dmitry Kravkov; Yuval Mintz
> Subject: [PATCH net] bnx2x: add missing napi deletion in error path
> 
> If the hardware initialization fails in bnx2x_nic_load() after adding
> napi objects, they would not be deleted. A subsequent attempt to unload
> the bnx2x module detects a corruption in the napi list.
> 
> Add the missing napi deletion to the error path.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index a923bc4..4046f97 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -2760,6 +2760,7 @@ load_error2:
>  	bp->port.pmf = 0;
>  load_error1:
>  	bnx2x_napi_disable(bp);
> +	bnx2x_del_all_napi(bp);
> 
>  	/* clear pf_load status, as it was already set */
>  	if (IS_PF(bp))
> --
> 1.8.1.4
>
Thanks, Michal!

Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
 
