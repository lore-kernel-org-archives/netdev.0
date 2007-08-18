From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] restore netdev_priv optimization (planb)
Date: Fri, 17 Aug 2007 18:00:06 -0700 (PDT)
Message-ID: <20070817.180006.98552435.davem@davemloft.net>
References: <20070817161928.6b6302fd@freepuppy.rosehill.hemminger.net>
	<20070817.165625.23014105.davem@davemloft.net>
	<20070817174909.5e890ad6@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751190AbXHRBAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:00:08 -0400
In-Reply-To: <20070817174909.5e890ad6@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 17 Aug 2007 17:49:09 -0700

> Fix optimization of netdev_priv() lost by the addition of multiqueue.
> 
> Only configurations that define MULITQUEUE need the extra overhead in
> netdevice structure and the loss of the netdev_priv optimization.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Every distribution vendor is going to turn MULTIQUEUE on.  Therefore
%99 of Linux users will not see any gain from your patch.

You're walking around in a dark room and hitting walls every
few seconds.  Take a moment and think about how to really deal
with this generically for a second before churning out another
patch.

For example, how about making the multiqueue limit fixed, say at 64
queues, and declare the egress_queues as an array of 64 entries.  Then
you can get constant pointer formation for both the netdev priv and
the queues.

This will also basically eliminate all of the alloc_mqueue() logic,
since struct netdev will now always be a fixed size.

And, amazingly, this deals with the loopback issue transparently as
well. :-)

It would also be nice to just get rid of netdev->priv, it will prevent
more misuses like the cxgb3 case, for example.
