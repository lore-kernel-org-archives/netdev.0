From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v6 2/7] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Tue, 13 Nov 2012 07:30:22 -0800
Message-ID: <1352820622.24230.31.camel@joe-AO722>
References: <1352818843-4457-1-git-send-email-thomas.petazzoni@free-electrons.com>
	 <1352818843-4457-3-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52536 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751576Ab2KMPaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 10:30:20 -0500
In-Reply-To: <1352818843-4457-3-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 16:00 +0100, Thomas Petazzoni wrote:
> This patch contains a new network driver for the network unit of the
> ARM Marvell Armada 370 and the Armada XP. Both SoCs use the PJ4B
> processor, a Marvell-developed ARM core that implements the ARMv7
> instruction set.

This looks very clean to me.

trivial:
some of the logging doesn't use terminating newlines.

> +static int mvneta_check_mtu_valid(struct net_device *dev, int mtu)
> +{
[]
> +       if (mtu > 9676) {
> +               netdev_info(dev, "Illegal MTU value %d, round to 9676", mtu);
[]
> +	if (!IS_ALIGNED(MVNETA_RX_PKT_SIZE(mtu), 8)) {
> +		netdev_info(dev, "Illegal MTU value %d, rounding to %d",

missing newlines

> +static int __devinit mvneta_probe(struct platform_device *pdev)
[]
> +	if (register_netdev(dev)) {
> +		dev_err(&pdev->dev, "failed to register\n");
> +		err = ENOMEM;
> +		goto err_base;
> +	}
[]
> +	dev_info(&pdev->dev, "%s, mac: %pM\n", dev->name,
> +		 dev->dev_addr);

You could use netdev_info here

	netdev_info(dev, "mac: %pM\n", dev->dev_addr);
