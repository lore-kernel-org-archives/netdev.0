From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4 3/5] fib_trie: dump doesnt use RCU
Date: Wed, 23 Jan 2008 23:27:47 -0800 (PST)
Message-ID: <20080123.232747.75654058.davem@davemloft.net>
References: <20080123.205007.16809712.davem@davemloft.net>
	<47983304.3030309@trash.net>
	<479833EE.1090905@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60180
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750928AbYAXH1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 02:27:37 -0500
In-Reply-To: <479833EE.1090905@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 23 Jan 2008 22:45:02 -0800

> Yes, I tested, no the assert didn't hit... Actually, the reason I went 
> down this path was
> because I couldn't trigger -EBUSY with concurrent updates.
> 
> P.s: I checked and Quagga handles -EAGAIN, so if you need an error code that
> would be the one to use.

Ok, but see my other email, the -EBUSY block can't be removed.

Even though for any given ->dump() call RTNL is held, it
is dropped before the next ->dump() call on the same
piece of nlk->cb[] state.

So the node for the nlk->cb->args[2] key can go away due
to an intervening table change.
