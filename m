From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 6/7] bna: Add Callback to Fix RXQ Stop
Date: Fri, 23 Sep 2011 19:38:31 -0700
Message-ID: <1316831912.28330.19.camel@Joe-Laptop>
References: <1316830458-24773-1-git-send-email-rmody@brocade.com>
	 <1316830458-24773-7-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37598 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752043Ab1IXCic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 22:38:32 -0400
In-Reply-To: <1316830458-24773-7-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-23 at 19:14 -0700, Rasesh Mody wrote:
> diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
[]
> @@ -956,6 +956,27 @@ bnad_cb_tx_cleanup(struct bnad *bnad, struct bna_tx *tx)
>  }
>  
>  static void
> +bnad_cb_rx_stall(struct bnad *bnad, struct bna_rx *rx)
> +{
> +	struct bnad_rx_info *rx_info = (struct bnad_rx_info *)rx->priv;
> +	struct bna_ccb *ccb;
> +	struct bnad_rx_ctrl *rx_ctrl;
> +	int i;
> +
> +	for (i = 0; i < BNAD_MAX_RXP_PER_RX; i++) {
> +		rx_ctrl = &rx_info->rx_ctrl[i];
> +		ccb = rx_ctrl->ccb;
> +		if (!ccb)
> +			continue;
> +
> +	clear_bit(BNAD_RXQ_POST_OK, &ccb->rcb[0]->flags);
> +
> +	if (ccb->rcb[1])
> +		clear_bit(BNAD_RXQ_POST_OK, &ccb->rcb[1]->flags);

misleading indentation.  Please add a tab.

> +	}
> +}
> +
