From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/3] netxen: enable LRO based on NETIF_F_LRO
Date: Fri, 31 Dec 2010 10:58:12 -0800 (PST)
Message-ID: <20101231.105812.39181789.davem@davemloft.net>
References: <1293439423-25193-1-git-send-email-amit.salecha@qlogic.com>
	<1293439423-25193-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, sucheta.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37670
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753166Ab0LaS5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 13:57:41 -0500
In-Reply-To: <1293439423-25193-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon, 27 Dec 2010 00:43:42 -0800

> +	if (!!data) {

This form of the test is not only unnecessary, it's ugly.  Please just
test plain "data".

> +		dev->features &= ~NETIF_F_LRO;
> +		netxen_send_lro_cleanup(adapter);
> +		dev_info(&adapter->pdev->dev,
> +					"disabling LRO as rx_csum is off\n");

You should use netdev_info() and fix the tabbing here.

> +	if (!adapter->rx_csum) {
> +		dev_info(&adapter->pdev->dev, "rx csum is off, "
> +			"cannot toggle LRO\n");
> +		return -EINVAL;
> +	}

Please use netdev_info().
