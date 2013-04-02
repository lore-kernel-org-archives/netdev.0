From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Tue, 2 Apr 2013 17:58:22 +0200
Message-ID: <20130402155822.GB29115@redhat.com>
References: <1364917500.5113.176.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932352Ab3DBP6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:58:41 -0400
Content-Disposition: inline
In-Reply-To: <1364917500.5113.176.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 02, 2013 at 08:45:00AM -0700, Eric Dumazet wrote:
>From: Eric Dumazet <edumazet@google.com>
>
>commit 00cfec37484761 (net: add a synchronize_net() in
>netdev_rx_handler_unregister())
>allows us to remove the synchronized_net() call from del_nbp()
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>Cc: Stephen Hemminger <stephen@networkplumber.org>
>---
> net/bridge/br_if.c |    1 -
> 1 file changed, 1 deletion(-)
>
>diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>index ef1b914..f17fcb3 100644
>--- a/net/bridge/br_if.c
>+++ b/net/bridge/br_if.c
>@@ -148,7 +148,6 @@ static void del_nbp(struct net_bridge_port *p)
> 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
>
> 	netdev_rx_handler_unregister(dev);
>-	synchronize_net();
>
> 	netdev_upper_dev_unlink(dev, br->dev);
>
>
>

Thanks, didn't see that when fixing bonding.

Acked-by: Veaceslav Falico <vfalico@redhat.com>
