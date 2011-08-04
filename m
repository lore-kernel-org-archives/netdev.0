From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] macb: restore wrap bit when performing underrun cleanup
Date: Thu, 04 Aug 2011 09:58:45 +0100
Message-ID: <4E3A5F45.9020609@atmel.com>
References: <> <1312445507-31382-1-git-send-email-tord.andersson@endian.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Tord Andersson <tord.andersson@endian.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:4570 "EHLO sjogate2.atmel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116Ab1HDI7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 04:59:00 -0400
In-Reply-To: <1312445507-31382-1-git-send-email-tord.andersson@endian.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2011 09:11 AM, Tord Andersson wrote:
> When TX underrun occurs, a cleanup is performed that marks all buffers as used. As a side effect it also clears the wrap bit in the last buffer. This patch will restore the wrap bit.
>
> Signed-off-by: Tord Andersson<tord.andersson@endian.se>

Thanks for fixing this.

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>   drivers/net/macb.c |    3 +++
>   1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index 0fcdc25..dc4e305 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -322,6 +322,9 @@ static void macb_tx(struct macb *bp)
>   		for (i = 0; i<  TX_RING_SIZE; i++)
>   			bp->tx_ring[i].ctrl = MACB_BIT(TX_USED);
>
> +		/* Add wrap bit */
> +		bp->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
> +
>   		/* free transmit buffer in upper layer*/
>   		for (tail = bp->tx_tail; tail != head; tail = NEXT_TX(tail)) {
>   			struct ring_info *rp =&bp->tx_skb[tail];


-- 
Nicolas Ferre
