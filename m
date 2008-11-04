From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix run pending DAD when interface becomes ready
Date: Tue, 04 Nov 2008 14:51:22 -0800 (PST)
Message-ID: <20081104.145122.25920326.davem@davemloft.net>
References: <20081104135549.981972492@nptl.frec.bull.fr>
	<20081104135551.916564770@nptl.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754987AbYKDWvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 17:51:47 -0500
In-Reply-To: <20081104135551.916564770@nptl.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Tue, 04 Nov 2008 14:55:50 +0100

> I think there's a bug in net/ipv6/addrconf.c, addrconf_notify():
> addrconf_dad_run() is not always run when the interface is flagged IF_READY.
> Currently it is only run when receiving NETDEV_CHANGE event. Looks like
> some (virtual) devices doesn't send this event when becoming up.
> 
> For both NETDEV_UP and NETDEV_CHANGE events, when the interface becomes
> ready, run_pending should be set to 1. Patch below.
> 
> 'run_pending = 1' could be moved below the if/else block but it makes 
> the code less readable.

I wonder if we should instead make the virtual devices emit
the missing event?
