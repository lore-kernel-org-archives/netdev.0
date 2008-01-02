From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [BRIDGE] Remove useless code in
 net/bridge/br_netfilter.c
Date: Tue, 01 Jan 2008 21:20:26 -0800 (PST)
Message-ID: <20080101.212026.187527188.davem@davemloft.net>
References: <eb3ff54b0801010248t65d296ccm481202d50fad7c4f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751489AbYABFU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 00:20:27 -0500
In-Reply-To: <eb3ff54b0801010248t65d296ccm481202d50fad7c4f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 1 Jan 2008 12:48:14 +0200

> These following two commands in br_nf_forward_arp() achieve nothing and
> should be removed; the d variable is not used later in this method:
> 
> 	...
> 	struct net_device **d = (struct net_device **)(skb->cb);
> 	...
> 	*d = (struct net_device *)in;
> 	...
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

It's a pointer dereference assignment, this last line has a
side effect, therefore you can't remove it.

The code is equivalent to:

struct skb_bridge_info {
	struct net_device *dev;
};

	struct skb_bridge_info *d;

	d = (struct skb_bridge_info *) skb->cb;

	d->dev = in;

What automated tool showed this as useless to you?

Please correct it's logic so it doesn't mark real side effects like
this as superfluous.

Thanks.
