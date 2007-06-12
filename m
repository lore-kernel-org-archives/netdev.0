From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] [RFC -v3] NET: Implement a standard ndev_printk family
Date: Tue, 12 Jun 2007 09:52:01 -0700
Message-ID: <1181667121.6020.56.camel@localhost>
References: <20070612004009.1545.12076.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, shemminger@linux-foundation.org,
	randy.dunlap@oracle.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4754 "EHLO Perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641AbXFLQwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 12:52:06 -0400
In-Reply-To: <20070612004009.1545.12076.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-11 at 17:40 -0700, Auke Kok wrote:
> +#define ndev_err(netdev, level, format, arg...) \
> +	do { \
> +		struct net_device *__nd = (netdev); \
> +		if ((__nd)->msg_enable & NETIF_MSG_##level) \
> +			printk(KERN_ERR "%s: %s: " format, (__nd)->name, \
> +				(__nd)->dev.parent->bus_id, ## arg); \
> +	} while (0)
> +

I think it's better to remove the macro concatenation/obfuscation
of the NETIF_MSG_##level argument and simply pass the appropriate
NETIF_MSG_<type> directly to these ndev_<level> calls.

It would also simplify the more than 300 calls in drivers/net of

	if (netif_msg_<type>(ptr))
		printk(foo)

to

	ndev_<level>(netdev, NETIF_MSG_<type>, fmt, args)


