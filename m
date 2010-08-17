From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv3 NEXT 7/7] qlcnic: turn off lro when rxcsum is
 disabled.
Date: Tue, 17 Aug 2010 07:48:52 -0700
Message-ID: <1282056532.24541.89.camel@Joe-Laptop>
References: <1282041265-32591-1-git-send-email-amit.salecha@qlogic.com>
	 <1282041265-32591-8-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1115 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754255Ab0HQOsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 10:48:54 -0400
In-Reply-To: <1282041265-32591-8-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-17 at 03:34 -0700, Amit Kumar Salecha wrote:
> From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Thanks all, 2 minor comments below.

> --- a/drivers/net/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/qlcnic/qlcnic_ethtool.c
> @@ -818,7 +818,21 @@ static u32 qlcnic_get_rx_csum(struct net_device *dev)
>  static int qlcnic_set_rx_csum(struct net_device *dev, u32 data)
[]
> 	dev_info(&adapter->pdev->dev, "disabling LRO as rx_csum is off\n");

I think netdev_<level> should be used when a
struct net_device * is available.

	netdev_info(dev, "disabling LRO as rx_csum is off\n");

> @@ -1001,6 +1015,15 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
[]
> +	if (!adapter->rx_csum) {
> +		dev_info(&adapter->pdev->dev, "rx csum is off, "
> +			"cannot toggle lro\n");

		netdev_info(netdev, "rx csum is off, cannot toggle LRO\n");

and please use consistent acronym case.

