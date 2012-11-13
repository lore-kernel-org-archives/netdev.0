From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next PATCH] net/ethernet: remove useless
 is_valid_ether_addr from drivers ndo_open
Date: Tue, 13 Nov 2012 13:55:19 -0800
Message-ID: <20121113135519.1e02be53@nehalam.linuxnetplumber.net>
References: <1352843199-24869-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pcnet32@frontier.com, nicolas.ferre@atmel.com,
	mlindner@marvell.com, nico@fluxnic.net,
	steve.glendinning@shawell.net,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51492 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304Ab2KMV4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 16:56:22 -0500
In-Reply-To: <1352843199-24869-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Nov 2012 22:46:39 +0100
Joachim Eastwood <manabian@gmail.com> wrote:

> diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
> index d19a143..ce8d053 100644
> --- a/drivers/net/ethernet/marvell/skge.c
> +++ b/drivers/net/ethernet/marvell/skge.c
> @@ -2524,9 +2524,6 @@ static int skge_up(struct net_device *dev)
>  	size_t rx_size, tx_size;
>  	int err;
>  
> -	if (!is_valid_ether_addr(dev->dev_addr))
> -		return -EINVAL;
> -
>  	netif_info(skge, ifup, skge->netdev, "enabling interface\n");
>  
>  	if (dev->mtu > RX_BUF_SIZE)

This should probably stay since it costs so little and protects
against a obscure error case.
skge_up is called from skge_resume on resume from suspend.
It is possible that the device was zeroed after skge_suspend was
called.
