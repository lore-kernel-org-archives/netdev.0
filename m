From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] dp83640: Fix NOHZ local_softirq_pending 08 warning
Date: Wed, 11 Jan 2012 20:03:00 +0100
Message-ID: <20120111190300.GA14376@netboy.at.omicron.at>
References: <1326189135-27770-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:35570 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933111Ab2AKTDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 14:03:10 -0500
Received: by eekd4 with SMTP id d4so442932eek.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 11:03:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1326189135-27770-1-git-send-email-manfred.rudigier@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2012 at 10:52:15AM +0100, Manfred Rudigier wrote:
> Similar problem as in 481a8199142c050b72bff8a1956a49fd0a75bbe0. This fix
> replaces netif_rx() with netif_rx_ni() which has to be used from
> process/softirq context.

Thanks for spotting this. Can you post this once again with a Cc tag
for the stable branch, too?

Thanks,
Richard

> 
> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
> ---
>  drivers/net/phy/dp83640.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
> index 9663e0b..ba3c591 100644
> --- a/drivers/net/phy/dp83640.c
> +++ b/drivers/net/phy/dp83640.c
> @@ -1159,7 +1159,7 @@ static void rx_timestamp_work(struct work_struct *work)
>  			}
>  		}
>  		spin_unlock_irqrestore(&dp83640->rx_lock, flags);
> -		netif_rx(skb);
> +		netif_rx_ni(skb);
>  	}
>  
>  	/* Clear out expired time stamps. */
> -- 
> 1.7.0.4
> 
