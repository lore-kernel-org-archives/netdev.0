From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 3/7] r8169: stop delaying workqueue.
Date: Fri, 27 Jan 2012 13:20:13 -0800
Message-ID: <1327699213.19848.5.camel@joe2Laptop>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
	 <20120127205632.GC24507@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54031 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753724Ab2A0VUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jan 2012 16:20:30 -0500
In-Reply-To: <20120127205632.GC24507@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-27 at 21:56 +0100, Francois Romieu wrote:
> Though motivated by the move of the driver to a single work queue of
> sequential events and removal of hard irq processing, it looks safe as
> a standalone change.
[]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
[]
> @@ -714,7 +714,11 @@ struct rtl8169_private {
>  	unsigned int (*phy_reset_pending)(struct rtl8169_private *tp);
>  	unsigned int (*link_ok)(void __iomem *);
>  	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
> -	struct delayed_work task;
> +
> +	struct {
> +		struct work_struct work;
> +	} wk;

This struct is usefully expanded in patch 7/7.

Perhaps this should be mentioned in the changelog
otherwise the change looks rather suspect.
