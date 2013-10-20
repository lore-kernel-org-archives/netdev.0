From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 01/07] 8139too: Support for byte queue limits
Date: Sun, 20 Oct 2013 11:51:29 -0700
Message-ID: <1382295089.2041.42.camel@joe-AO722>
References: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
	 <1382292803-18875-2-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Tino Reichardt <milky-kernel@mcmilk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0196.hostedemail.com ([216.40.44.196]:57785 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751490Ab3JTSve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 14:51:34 -0400
In-Reply-To: <1382292803-18875-2-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-10-20 at 20:13 +0200, Tino Reichardt wrote:
> Changes to 8139too driver to use byte queue limits.
[]
> diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
[]
> @@ -1409,6 +1413,8 @@ static void rtl8139_hw_start (struct net_device *dev)
[]
>  	netdev_dbg(dev, "init buffer addresses\n");
> +	if (likely(bql_disable == false))
> +		netdev_reset_queue(dev);

Much prefer:

	if (unlikely(bql_disable))

> @@ -1639,6 +1645,9 @@ static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
[]
> +	if (likely(bql_disable == false))
> +		netdev_reset_queue(tp->dev);

etc...
