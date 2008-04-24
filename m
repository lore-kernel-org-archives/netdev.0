From: David Miller <davem@davemloft.net>
Subject: Re: mutex WARNING while running ip from iproute2 package
Date: Wed, 23 Apr 2008 20:20:50 -0700 (PDT)
Message-ID: <20080423.202050.255399231.davem@davemloft.net>
References: <200804201757.09938.denys@visp.net.lb>
	<20080423.194125.202757521.davem@davemloft.net>
	<480FFA8E.1040407@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752789AbYDXDUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 23:20:50 -0400
In-Reply-To: <480FFA8E.1040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 24 Apr 2008 05:12:14 +0200

> Sure. This seems to be the bogus ASSERT_RTNL warning caused
> by mutex_trylock() while holding a spinlock. The warning
> itself is harmless, since we're already holding the RTNL,
> mutex_trylock won't succeed.

I'm sorry, I had forgotten about this. :-/

> Herbert suggested to store address updates in atomic context
> on a temporary list and do the actual update in process
> context. This seems like a good idea to simplify the address
> list locking, unfortunately I didn't manage to take care of
> this yet. An alternative fix to silent the bogus warning would
> be to use mutex_is_locked in ASSERT_RTNL, but Herbert didn't
> like that idea.

I think we need something like the latter in any event.

