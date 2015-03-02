From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] net: add IPv4 routing FIB support for
 switchdev
Date: Mon, 02 Mar 2015 13:20:15 -0500 (EST)
Message-ID: <20150302.132015.1646795699731313510.davem@davemloft.net>
References: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
	<1425288555-22598-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757AbbCBSUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 13:20:18 -0500
In-Reply-To: <1425288555-22598-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Mon,  2 Mar 2015 01:29:13 -0800

> +	dev = netdev_switch_get_by_fib_dev(fi->fib_dev);
 ...
> +	dev = netdev_switch_get_by_fib_dev(fi->fib_dev);

I really should get rid of the fib_dev define, it's always trouble.

Routes can have multiple next hops, and when that is the case you
cannot offload them to hardware in your initial implementation here.

Next hops need to be iterated upon, and that currently can't be
modelled with your abstration right now.

I also don't see you testing properly for
net->ipv4.fib_has_custom_rules,

Oh, I see, that happens in patch #4.  Please make that logic present
from the very beginning.

If you see a multi-nexthop route, for this initial implementation,
you will need to uninstall all routes from the hardware.
