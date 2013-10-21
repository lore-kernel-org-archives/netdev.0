From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 2/5] net:stmmac: fix rx buffer allocation.
Date: Mon, 21 Oct 2013 10:54:46 +0200
Message-ID: <5264EBD6.7060302@st.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <1381937052-8999-3-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jimmy Perchet <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:46942 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754592Ab3JUIyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 04:54:52 -0400
In-Reply-To: <1381937052-8999-3-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
> Rx buffers used wrong size, because priv->dma_buf_sz was updated after allocation.
>
> Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 170f043..0015175 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -998,6 +998,9 @@ static int init_dma_desc_rings(struct net_device *dev)
>   	if (bfsize < BUF_SIZE_16KiB)
>   		bfsize = stmmac_set_bfsize(dev->mtu, priv->dma_buf_sz);
>
> +	priv->dma_buf_sz = bfsize;
> +	buf_sz = bfsize;
> +
>   	if (netif_msg_probe(priv))
>   		pr_debug("%s: txsize %d, rxsize %d, bfsize %d\n", __func__,
>   			 txsize, rxsize, bfsize);
> @@ -1087,8 +1090,6 @@ static int init_dma_desc_rings(struct net_device *dev)
>   	}
>   	priv->cur_rx = 0;
>   	priv->dirty_rx = (unsigned int)(i - rxsize);
> -	priv->dma_buf_sz = bfsize;
> -	buf_sz = bfsize;
>
>   	/* Setup the chained descriptor addresses */
>   	if (priv->mode == STMMAC_CHAIN_MODE) {
>
