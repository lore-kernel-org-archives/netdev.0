From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 4/7] bnx2x: simplify TPA sanity check
Date: Wed, 31 Aug 2011 13:22:14 +0300
Message-ID: <201108311322.15160.vladz@broadcom.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
 <1314714646-3642-5-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2651 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754537Ab1HaKWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 06:22:55 -0400
In-Reply-To: <1314714646-3642-5-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 30 August 2011 17:30:43 Michal Schmidt wrote:
> In the TPA branch we already know the CQE type is either START or STOP.
> No need to test for that. Even if the type were to differ, we wouldn't
> want to suppress the error message.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c index f1fea58..fe5be0c
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -634,9 +634,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
>  		if (!CQE_TYPE_FAST(cqe_fp_type)) {
>  #ifdef BNX2X_STOP_ON_ERROR
>  			/* sanity check */
> -			if (fp->disable_tpa &&
> -			    (CQE_TYPE_START(cqe_fp_type) ||
> -			     CQE_TYPE_STOP(cqe_fp_type)))
> +			if (fp->disable_tpa)
>  				BNX2X_ERR("START/STOP packet while "
>  					  "disable_tpa type %x\n",
>  					  CQE_TYPE(cqe_fp_type));

Acked-by: Vladislav Zolotarov <vladz@broadcom.com>
