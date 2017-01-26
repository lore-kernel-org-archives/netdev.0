From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] batman-adv: Treat NET_XMIT_CN as transmit
 successfully
Date: Wed, 25 Jan 2017 22:56:24 -0500 (EST)
Message-ID: <20170125.225624.965229145391320056.davem@davemloft.net>
References: <20170125164303.14268-1-sw@simonwunderlich.de>
        <20170125164303.14268-3-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        gfree.wind@gmail.com, sven@narfation.org
To: sw@simonwunderlich.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdAZD40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 22:56:26 -0500
In-Reply-To: <20170125164303.14268-3-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>
Date: Wed, 25 Jan 2017 17:42:58 +0100

> From: Gao Feng <gfree.wind@gmail.com>
> 
> The tc could return NET_XMIT_CN as one congestion notification, but
> it does not mean the packet is lost. Other modules like ipvlan,
> macvlan, and others treat NET_XMIT_CN as success too.
> 
> So batman-adv should add the NET_XMIT_CN check.
> 
> Signed-off-by: Gao Feng <gfree.wind@gmail.com>
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>

Instead of all of this churn, just change the dev_queue_xmit() call in
net/batman-adv/send.c to be:

	return net_xmit_eval(dev_queue_xmit(skb));
