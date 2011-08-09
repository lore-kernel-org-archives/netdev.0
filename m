From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] slip: fix NOHZ local_softirq_pending 08 warning
Date: Tue, 09 Aug 2011 19:07:29 +0200
Message-ID: <4E416951.4020207@hartkopp.net>
References: <CAKh5naYrNPG3UO02VzG13QUP-SOP8-Td+O0G5LAr-+npduP49A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:57116 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081Ab1HIRIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 13:08:22 -0400
In-Reply-To: <CAKh5naYrNPG3UO02VzG13QUP-SOP8-Td+O0G5LAr-+npduP49A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ilya,

is the processing of characters in the tty input stream for line disciplines
*always* done in softirq context???

If so, i would send a patch for drivers/net/can/slcan.c too ...

Thanks,
Oliver

On 05.08.2011 21:23, Matvejchikov Ilya wrote:
> When using nanosleep() in an userspace application we get a ratelimit warning:
> 
> 	NOHZ: local_softirq_pending 08
> 
> According to 481a8199142c050b72bff8a1956a49fd0a75bbe0 the problem is caused by
> netif_rx() function. This patch replaces netif_rx() with netif_rx_ni() which
> has to be used from process/softirq context.
> 
> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
> ---
>  drivers/net/slip.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/slip.c b/drivers/net/slip.c
> index f11b3f3..4c61753 100644
> --- a/drivers/net/slip.c
> +++ b/drivers/net/slip.c
> @@ -367,7 +367,7 @@ static void sl_bump(struct slip *sl)
>  	memcpy(skb_put(skb, count), sl->rbuff, count);
>  	skb_reset_mac_header(skb);
>  	skb->protocol = htons(ETH_P_IP);
> -	netif_rx(skb);
> +	netif_rx_ni(skb);
>  	dev->stats.rx_packets++;
>  }
> 

