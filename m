From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net 1/2] bnx2x: fix a crash on corrupt firmware file
Date: Fri, 16 Mar 2012 09:24:09 +0200
Message-ID: <1331882650.4251.9.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1331856509-9159-1-git-send-email-mschmidt@redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3553 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757424Ab2CPHYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 03:24:22 -0400
In-Reply-To: <1331856509-9159-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-16 at 01:08 +0100, Michal Schmidt wrote:
> If the requested firmware is deemed corrupt and then released, reset the
> pointer to NULL in order to avoid double-freeing it in
> bnx2x_release_firmware() or dereferencing it in bnx2x_init_firmware().
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Acked-by: Eilon Greenstein <eilong@broadcom.com>

Thanks Michal!

> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 2545213..00ff62f 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -10901,6 +10901,7 @@ init_ops_alloc_err:
>  	kfree(bp->init_data);
>  request_firmware_exit:
>  	release_firmware(bp->firmware);
> +	bp->firmware = NULL;
>  
>  	return rc;
>  }
