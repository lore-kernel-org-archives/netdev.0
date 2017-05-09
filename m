From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next] bnxt: add dma mapping attributes
Date: Tue, 9 May 2017 14:05:14 -0700
Message-ID: <CACKFLikw_oi4rHRC9P-23xuvuOJSaf9b2kUSeTMgbNW1WA__=w@mail.gmail.com>
References: <1494362253-270990-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, sparclinux@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33254 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdEIVFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 17:05:16 -0400
Received: by mail-lf0-f43.google.com with SMTP id r17so9366297lfg.0
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 14:05:15 -0700 (PDT)
In-Reply-To: <1494362253-270990-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 9, 2017 at 1:37 PM, Shannon Nelson
<shannon.nelson@oracle.com> wrote:
> On the SPARC platform we need to use the DMA_ATTR_WEAK_ORDERING attribute
> in our Rx path dma mapping in order to get the expected performance out
> of the receive path.  Adding it to the Tx path has little effect, so
> that's not a part of this patch.
>
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> Reviewed-by: Tushar Dave <tushar.n.dave@oracle.com>
> Reviewed-by: Tom Saeger <tom.saeger@oracle.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c |   61 ++++++++++++++++++----------
>  1 files changed, 39 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> index 1f1e54b..771742c 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -66,6 +66,12 @@
>  MODULE_DESCRIPTION("Broadcom BCM573xx network driver");
>  MODULE_VERSION(DRV_MODULE_VERSION);
>
> +#ifdef CONFIG_SPARC
> +#define BNXT_DMA_ATTRS  DMA_ATTR_WEAK_ORDERING
> +#else
> +#define BNXT_DMA_ATTRS 0
> +#endif
> +

I think we can use the same attribute for all architectures.
Architectures that don't implement weak ordering will ignore the
attribute.
