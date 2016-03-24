From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] net: macb: remove BUG_ON() and reset the queue to
 handle RX errors
Date: Thu, 24 Mar 2016 21:19:45 +0300
Message-ID: <56F42FC1.6000008@cogentembedded.com>
References: <1458830232-6159-1-git-send-email-cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	nicolas.ferre@atmel.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	soren.brinkmann@xilinx.com, narmstrong@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:35297 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbcCXSTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:19:52 -0400
Received: by mail-lb0-f179.google.com with SMTP id bc4so36362968lbc.2
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:19:51 -0700 (PDT)
In-Reply-To: <1458830232-6159-1-git-send-email-cyrille.pitchen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/24/2016 05:37 PM, Cyrille Pitchen wrote:

> This patch removes two BUG_ON() used to notify about RX queue corruptions
> on macb (not gem) hardware without actually handling the error.
>
> The new code skips corrupted frames but still processes faultless frames.
> Then it resets the RX queue before restarting the reception from a clean
> state.
>
> This patch is a rework of an older patch proposed by Neil Armstrong:
> http://patchwork.ozlabs.org/patch/371525/
>
> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> ---
>   drivers/net/ethernet/cadence/macb.c | 59 ++++++++++++++++++++++++++++++-------
>   1 file changed, 49 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 6619178ed77b..39447a337149 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
[...]
> @@ -945,11 +948,26 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
>   	return 0;
>   }
>
> +static inline void macb_init_rx_ring(struct macb *bp)
> +{
> +	int i;
> +	dma_addr_t addr;

    DaveM prefers that longer declarations precede the shorter.

[...]
>   static int macb_rx(struct macb *bp, int budget)
>   {
>   	int received = 0;
>   	unsigned int tail;
>   	int first_frag = -1;
> +	int reset_rx_queue = 0;

    *bool*, please.

[...]

MBR, Sergei
