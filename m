From: David Miller <davem@davemloft.net>
Subject: Re: PATCH] filter: fix sk_filter rcu handling
Date: Mon, 06 Dec 2010 09:29:59 -0800 (PST)
Message-ID: <20101206.092959.226787101.davem@davemloft.net>
References: <20101201.101809.71122121.davem@davemloft.net>
	<1291357953.2854.46.camel@edumazet-laptop>
	<1291582432.2806.300.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, xiaosuo@gmail.com, wirelesser@gmail.com,
	netdev@vger.kernel.org, xemul@openvz.org, stable@kernel.org,
	paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753203Ab0LFR3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 12:29:32 -0500
In-Reply-To: <1291582432.2806.300.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Dec 2010 21:53:52 +0100

> [PATCH] filter: fix sk_filter rcu handling
> 
> Pavel Emelyanov tried to fix a race between sk_filter_(de|at)tach and
> sk_clone() in commit 47e958eac280c263397
> 
> Problem is we can have several clones sharing a common sk_filter, and
> these clones might want to sk_filter_attach() their own filters at the
> same time, and can overwrite old_filter->rcu, corrupting RCU queues.
> 
> We can not use filter->rcu without being sure no other thread could do
> the same thing.
> 
> Switch code to a more conventional ref-counting technique : Do the
> atomic decrement immediately and queue one rcu call back when last
> reference is released.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, and queued up for -stable, thanks.
