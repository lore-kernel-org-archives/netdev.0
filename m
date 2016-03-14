From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Sun, 13 Mar 2016 21:50:33 -0400 (EDT)
Message-ID: <20160313.215033.17951850162749485.davem@davemloft.net>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbcCNBui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 21:50:38 -0400
In-Reply-To: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed,  9 Mar 2016 13:49:49 -0800

> This does happen as expected for egress traffic however on ingress
> traffic, the IPvlan packet-handler changes the skb->dev and this
> forces packet to be processed with the IPvlan slave and it's
> associated ns. This causes above mentioned problem and few other
> which are not yet reported / attempted. e.g.  IPsec with L3 mode or
> even ingress routing.

And now your changes make it so that we can't run netfilter rules on
the slave's device within the slave's ns.

If someone is doing that now you're breaking things for them.

It doesn't matter whether doing so or not makes sense.

You're going to have to find a way to do both, and also I'm concerned
about how you're leaking the source namespace's "stuff" into the
destination's.  That's very worrisome to me.

There is no way I'm applying this as-is, sorry.
