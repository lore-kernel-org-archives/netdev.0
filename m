From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix run pending DAD when interface becomes ready
Date: Wed, 05 Nov 2008 01:44:46 -0800 (PST)
Message-ID: <20081105.014446.140069453.davem@davemloft.net>
References: <20081104135549.981972492@nptl.frec.bull.fr>
	<20081104135551.916564770@nptl.frec.bull.fr>
	<20081104.145122.25920326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60778
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754227AbYKEJpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:45:11 -0500
In-Reply-To: <20081104.145122.25920326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 04 Nov 2008 14:51:22 -0800 (PST)

> From: Benjamin Thery <benjamin.thery@bull.net>
> Date: Tue, 04 Nov 2008 14:55:50 +0100
> 
> > I think there's a bug in net/ipv6/addrconf.c, addrconf_notify():
> > addrconf_dad_run() is not always run when the interface is flagged IF_READY.
> > Currently it is only run when receiving NETDEV_CHANGE event. Looks like
> > some (virtual) devices doesn't send this event when becoming up.
> > 
> > For both NETDEV_UP and NETDEV_CHANGE events, when the interface becomes
> > ready, run_pending should be set to 1. Patch below.
> > 
> > 'run_pending = 1' could be moved below the if/else block but it makes 
> > the code less readable.
> 
> I wonder if we should instead make the virtual devices emit
> the missing event?

In any event, for the time being, I'm going to apply
Benjamin's patch to fix this problem.

It makes the function in question logically consistent
in that now everything that can cause IF_READY to become
set will also cause run_pending work to run.
