From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2 5/6] bnx2x: fix PTE write access error
Date: Thu, 18 Jul 2013 01:51:37 +0400
Message-ID: <51E711E9.7030500@cogentembedded.com>
References: <1374097512-19540-1-git-send-email-dmitry@broadcom.com> <1374097512-19540-6-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:48686 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542Ab3GQVvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 17:51:36 -0400
Received: by mail-la0-f53.google.com with SMTP id fj20so168603lab.40
        for <netdev@vger.kernel.org>; Wed, 17 Jul 2013 14:51:34 -0700 (PDT)
In-Reply-To: <1374097512-19540-6-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/18/2013 01:45 AM, Dmitry Kravkov wrote:

> From: Barak Witkowsky <barak@broadcom.com>

> PTE write access error  might occur in MF_ALLOWED mode when IOMMU
> is active. The patch adds rmmod HSI indicating to MFW to stop
> running queries which might trigger this failure.

> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

    Not signed off by the author?

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 0f3de02..9394b7d 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c

> @@ -12824,6 +12828,11 @@ static void __bnx2x_remove(struct pci_dev *pdev,
>   	bnx2x_dcbnl_update_applist(bp, true);
>   #endif
>
> +	if ((IS_PF(bp)) &&

    () not needed.

> +	    (!BP_NOMCP(bp)) &&

    Likewise.

> +	    (bp->flags & BC_SUPPORTS_RMMOD_CMD))
> +		bnx2x_fw_command(bp, DRV_MSG_CODE_RMMOD, 0);
> +

WBR, Sergei
