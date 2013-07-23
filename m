From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 08:54:36 -0700
Message-ID: <20130723085436.70e8588c@nehalam.linuxnetplumber.net>
References: <4961229.bXDGvH0dpz@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61416 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab3GWPyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 11:54:39 -0400
Received: by mail-pd0-f176.google.com with SMTP id t12so8250405pdi.35
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 08:54:38 -0700 (PDT)
In-Reply-To: <4961229.bXDGvH0dpz@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Jul 2013 11:55:57 +0200
Peter Wu <lekensteyn@gmail.com> wrote:

> This message was added in commit a7154cb8 (June 2004) and is printed
> every ten seconds when no cable is connected.
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> ---
> Using ethtool to silence *all* link warnings is still a manual
> operation, in my opinion not acceptable so let's remove this message.
> 
> The r8169 constantly resets the device when no link is connected,
> contrary the r8168 vendor driver which only resets the link when some
> PCI config fields have been modified. As the current reset logic in r8168
> seems to work for broken device (which I do not have have and therefore
> cannot test), I did not attempt to "clean this up".
> ---
>  drivers/net/ethernet/realtek/r8169.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 880015c..63f04af 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -3689,8 +3689,6 @@ static void rtl_phy_work(struct rtl8169_private *tp)
>  	if (tp->link_ok(ioaddr))
>  		return;
>  
> -	netif_warn(tp, link, tp->dev, "PHY reset until link up\n");
> -
>  	tp->phy_reset_enable(tp);
>  
>  out_mod_timer:

Why not implement netif msg flag to allow user to control this?
