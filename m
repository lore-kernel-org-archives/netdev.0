From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH net v2 2/2] net: ethoc: Correctly pad short packets
Date: Tue, 12 Jul 2016 15:24:40 +0300
Message-ID: <20160712122440.GA19495@octofox.metropolis>
References: <1468280155-13152-1-git-send-email-f.fainelli@gmail.com>
 <1468280155-13152-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	colin.king@canonical.com, tklauser@distanz.ch,
	thierry.reding@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34666 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbcGLMYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 08:24:49 -0400
Received: by mail-lf0-f66.google.com with SMTP id a10so718123lfb.1
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 05:24:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468280155-13152-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Jul 11, 2016 at 04:35:55PM -0700, Florian Fainelli wrote:
> Even though the hardware can be doing zero padding, we want the SKB to
> be going out on the wire with the appropriate size. This fixes packet
> truncations observed with e.g: ARP packets.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/ethoc.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
> index 06ae14a8e946..ca678d46c322 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -860,6 +860,11 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	unsigned int entry;
>  	void *dest;
>  
> +	if (skb_put_padto(skb, ETHOC_ZLEN)) {
> +		dev->stats.tx_errors++;
> +		goto out;
> +	}

skb_put_padto says that skb is freed on error, so this shoudn't go to
label 'out' on error where skb is freed again?

-- 
Thanks.
-- Max
