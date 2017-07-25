From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH net-next 10/18] net: mvpp2: use the GoP interrupt for
 link status changes
Date: Tue, 25 Jul 2017 15:17:48 +0200
Message-ID: <20170725151748.22268390@windsurf.lan>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
        <20170724134848.19330-11-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:54002 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751097AbdGYNRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 09:17:50 -0400
In-Reply-To: <20170724134848.19330-11-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, 24 Jul 2017 15:48:40 +0200, Antoine Tenart wrote:
> +
> +		port->link_irq = of_irq_get_byname(port_node, "link");
> +		if (port->link_irq == -EPROBE_DEFER) {
> +			err = -EPROBE_DEFER;
> +			goto err_free_irq;
> +		}
> +		if (port->link_irq <= 0)
> +			/* the link irq is optional */
> +			port->link_irq = 0;

You need to add the irq_dispose_mapping() call corresponding to this
of_irq_get_by_name() in the error path and in the remove path.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
