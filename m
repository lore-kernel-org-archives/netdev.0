From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next]r8169.c: Force transmission when nic refuse to
 start.
Date: Fri, 14 Aug 2015 21:27:00 +0200
Message-ID: <20150814192700.GA17284@electric-eye.fr.zoreil.com>
References: <1439539107-13638-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40004 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbHNT1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 15:27:21 -0400
Content-Disposition: inline
In-Reply-To: <1439539107-13638-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index eb2d2a4..6882eab 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7470,15 +7470,22 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
>  	u16 enable_mask = RTL_EVENT_NAPI | tp->event_slow;
>  	int work_done= 0;
>  	u16 status;
> +        int tx_force = 1;
>  
>  	status = rtl_get_events(tp);
>  	rtl_ack_events(tp, status & ~tp->event_slow);
> -
> +       if (netif_running(dev)) {
>  	if (status & RTL_EVENT_NAPI_RX)
>  		work_done = rtl_rx(dev, tp, (u32) budget);
> +                
>  
>  	if (status & RTL_EVENT_NAPI_TX)
>  		rtl_tx(dev, tp);
> +         else if (tx_force == 1) {
> +                mdelay(10);
> +                rtl_tx(dev, tp);
> +         }
> +        }

Please try to use TimerInt instead of this ugly hack.

-- 
Ueimor
