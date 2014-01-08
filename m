From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: fix vif tx queue race in
 xenvif_rx_interrupt
Date: Wed, 08 Jan 2014 15:11:39 -0500 (EST)
Message-ID: <20140108.151139.4522881609697040.davem@davemloft.net>
References: <1389209061-29494-1-git-send-email-jieyue.majy@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	jieyue.majy@alibaba-inc.com, yingbin.wangyb@alibaba-inc.com,
	tienan.ftn@alibaba-inc.com, wei.liu2@citrix.com,
	ian.campbell@citrix.com, david.vrabel@citrix.com
To: majieyue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbaAHULm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 15:11:42 -0500
In-Reply-To: <1389209061-29494-1-git-send-email-jieyue.majy@alibaba-inc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ma JieYue <majieyue@gmail.com>
Date: Thu,  9 Jan 2014 03:24:21 +0800

> -	if (xenvif_rx_schedulable(vif))
> +	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif))

I do not see anything which prevents a netif_stop_queue() call from happening
between these two tests in another thread of control.

This therefore looks like a bandaid and not a real fix.
