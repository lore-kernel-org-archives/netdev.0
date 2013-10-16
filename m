From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 3/5] net:stmmac: ensure we reclaim all dirty descriptors.
Date: Wed, 16 Oct 2013 21:46:05 +0400
Message-ID: <525ED0DD.9070201@cogentembedded.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <1381937052-8999-4-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: Jimmy Perchet <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:41856 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934767Ab3JPRrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 13:47:08 -0400
Received: by mail-lb0-f180.google.com with SMTP id q8so908226lbi.25
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 10:47:07 -0700 (PDT)
In-Reply-To: <1381937052-8999-4-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/16/2013 07:24 PM, Jimmy Perchet wrote:

> On low speed link (10MBit/s), some TX descriptors can remain dirty
> if the tx coalescence timer expires before they were treated. Re-arm timer
> in this case.

> Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 0015175..af04b5d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1284,8 +1284,12 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>   			p = priv->dma_tx + entry;
>
>   		/* Check if the descriptor is owned by the DMA. */
> -		if (priv->hw->desc->get_tx_owner(p))
> +		if (priv->hw->desc->get_tx_owner(p)) {
> +			/* Be sure to harvest remaining descriptor. */
> +			mod_timer(&priv->txtimer,
> +			  STMMAC_COAL_TIMER(priv->tx_coal_timer));

   The continuation line should stat right under &, according to thenetworking 
coding style.

WBR, Sergei
