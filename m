From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH 1/2] bnx2x:Fix error handling in the function
 bnxc2x_dbcx_set_params
Date: Sun, 19 Jul 2015 06:51:16 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DEB75E@avmb3.qlogic.org>
References: <1437225397-26079-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53562 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750793AbbGSGvU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2015 02:51:20 -0400
In-Reply-To: <1437225397-26079-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This fixes the error handling in the function bnxc2x_dbcx_params for both calls
> to bnx2x_dcbnl_update_applist by checking if they failed by returning a error
> code and if so return immediately to this function's caller due to this
> nonrecoverable internal failure.

Hi Nicholas,

Even assuming this is the reasonable thing to do [which I'm not fully convinced],
I don't think this solution is complete - you'd also need to break the iteration in
bnx2x_dcbnl_update_applist() [at the moment said function always returns 'rc'
from the last dcb_app weve tried setting].

Also, why do you send multiple patches for fixing the same issue in different
functions in the same file?

Thanks,
Yuval

> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> index 6e4294e..e3cd0c6 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
> @@ -724,7 +724,8 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32
> state)
>  			 * Delete app tlvs from dcbnl before reading new
>  			 * negotiation results
>  			 */
> -			bnx2x_dcbnl_update_applist(bp, true);
> +			if (bnx2x_dcbnl_update_applist(bp, true))
> +				return;
> 
>  			/* Read remote mib if dcbx is in the FW */
>  			if (bnx2x_dcbx_read_shmem_remote_mib(bp))
> @@ -748,7 +749,8 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32
> state)
>  			/*
>  			 * Add new app tlvs to dcbnl
>  			 */
> -			bnx2x_dcbnl_update_applist(bp, false);
> +			if (bnx2x_dcbnl_update_applist(bp, false))
> +				return;
>  #endif
>  			/*
>  			 * reconfigure the netdevice with the results of the new
> --
> 2.1.4
