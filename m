From: Glen Gray <glen.gray@lincor.com>
Subject: Re: [PATCH 1/2] r8169: multicast register update (sync with Realtek's 8.004.00 8168 driver)
Date: Mon, 30 Jun 2008 11:02:57 +0100
Message-ID: <5B0BE23C-3952-40DB-94B5-453417DA21D4@lincor.com>
References: <20080629131739.GA31201@electric-eye.fr.zoreil.com> <20080629131852.GB31201@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail151.emailantidote.com ([80.169.59.151]:3073 "EHLO
	mail2.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754920AbYF3KO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 06:14:26 -0400
In-Reply-To: <20080629131852.GB31201@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Francois,

Do you think this might resolve my issues with multicast SAP  
announcements ?
--
Glen Gray <glen.gray@lincor.com>         Digital Depot, Thomas Street
Software Engineering Manager                        Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682

On 29 Jun 2008, at 14:18, Francois Romieu wrote:

> The layout of the 8168 serie is different from that of the 8110 one.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
> ---
> drivers/net/r8169.c |    6 ++++--
> 1 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 6572425..9086e81 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -3098,8 +3098,10 @@ static void rtl_set_rx_mode(struct net_device  
> *dev)
> 	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
> 	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
> 	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
> -		mc_filter[0] = 0xffffffff;
> -		mc_filter[1] = 0xffffffff;
> +		u32 data = mc_filter[0];
> +
> +		mc_filter[0] = swab32(mc_filter[1]);
> +		mc_filter[1] = swab32(data);
> 	}
>
> 	RTL_W32(MAR0 + 0, mc_filter[0]);
> -- 
> 1.5.3.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

