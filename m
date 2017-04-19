From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net 3/4] qed: Fix possible system hang in the
 dcbnl-getdcbx() path.
Date: Wed, 19 Apr 2017 09:56:36 -0400 (EDT)
Message-ID: <1873138594.16006381.1492610196115.JavaMail.zimbra@redhat.com>
References: <20170419101955.26444-1-sudarsana.kalluru@cavium.com> <20170419101955.26444-4-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51010 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934640AbdDSN4h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 09:56:37 -0400
In-Reply-To: <20170419101955.26444-4-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Sudarsana Reddy Kalluru" <sudarsana.kalluru@cavium.com>
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org, "Yuval Mintz" <Yuval.Mintz@cavium.com>
> Sent: Wednesday, 19 April, 2017 6:19:54 AM
> Subject: [PATCH net 3/4] qed: Fix possible system hang in the dcbnl-getdcbx() path.
> 
> qed_dcbnl_get_dcbx() API uses kmalloc in GFT_KERNEL mode. The API gets
> invoked in the interrupt context by qed_dcbnl_getdcbx callback. Need
> to invoke this kmalloc in atomic mode.
> 
> Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
> b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
> index ff058a3..8f0783a 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
> @@ -1264,7 +1264,7 @@ static struct qed_dcbx_get *qed_dcbnl_get_dcbx(struct
> qed_hwfn *hwfn,
>  {
>  	struct qed_dcbx_get *dcbx_info;
>  
> -	dcbx_info = kzalloc(sizeof(*dcbx_info), GFP_KERNEL);
> +	dcbx_info = kmalloc(sizeof(*dcbx_info), GFP_ATOMIC);

You are changing a kzalloc to kmalloc, was that intentional?

>  	if (!dcbx_info)
>  		return NULL;
>  
> --
> 1.8.3.1
> 
> 
