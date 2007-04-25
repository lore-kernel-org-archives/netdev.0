From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Wed, 25 Apr 2007 15:14:40 +0200
Message-ID: <462F5440.8020808@trash.net>
References: <20070424124250.d55789cd.akpm@linux-foundation.org> <20070424.142008.35506725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63891 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992741AbXDYNPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 09:15:05 -0400
In-Reply-To: <20070424.142008.35506725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I think I see what might be the problem, nlk->cb_mutex is set
> to "rtnl_mutex" and this is used for other purposes in various
> code paths here, maybe there is a double mutex_unlock() or
> similar due to that?


Nothing in the callbacks should be touching the rtnl, that would
have been broken before since we already used to hold it during
the first invocation of the dump callback, the only difference
is that we now hold it during the entire dump operation. The
cb_mutex is only set on socket creation, so there's also nothing
that should be rewriting it.

I can't see whats wrong here.
