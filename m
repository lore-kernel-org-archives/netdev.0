From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next v2] fec: Staticize fec_enet_select_queue()
Date: Fri, 19 Sep 2014 13:55:14 -0500
Message-ID: <CAHrpEqQ3zQHqGnF_cZb_MSSwrbu10O6XRzsOn3DK79KQ=o26mw@mail.gmail.com>
References: <1411149574-26296-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:32831 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756771AbaISSzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 14:55:16 -0400
Received: by mail-la0-f44.google.com with SMTP id q1so3754520lam.3
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 11:55:14 -0700 (PDT)
In-Reply-To: <1411149574-26296-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 12:59 PM, Fabio Estevam
<fabio.estevam@freescale.com> wrote:
> fec_enet_select_queue() is only used locally, so mark it as 'static' to fix the
> following sparse warning:
>
> drivers/net/ethernet/freescale/fec_main.c:2707:5: warning: symbol 'fec_enet_select_queue' was not declared. Should it be static?
>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Acked-by: Frank Li <Frank.Li@freescale.com>

> ---
> Changes since v1:
> - Make checkpatch happy
>
>  drivers/net/ethernet/freescale/fec_main.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 6e93336..2389dff 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2704,8 +2704,9 @@ static int fec_set_features(struct net_device *netdev,
>         return 0;
>  }
>
> -u16 fec_enet_select_queue(struct net_device *ndev, struct sk_buff *skb,
> -                         void *accel_priv, select_queue_fallback_t fallback)
> +static u16 fec_enet_select_queue(struct net_device *ndev, struct sk_buff *skb,
> +                                void *accel_priv,
> +                                select_queue_fallback_t fallback)
>  {
>         return skb_tx_hash(ndev, skb);
>  }
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
