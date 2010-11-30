From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 21:53:03 -0800 (PST)
Message-ID: <20101129.215303.48488457.davem@davemloft.net>
References: <AANLkTin11AYaFWMArC6fNQnvej2+=WUfOtTVrtX8WLEZ@mail.gmail.com>
	<20101129.212222.115953137.davem@davemloft.net>
	<1291095736.2725.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55384
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750949Ab0K3Fwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 00:52:37 -0500
In-Reply-To: <1291095736.2725.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Nov 2010 06:42:16 +0100

> Its a bit early in the morning here, I must confess I dont yet
> understand your patch David :)
> 
> As we use a tree, why not using two different trees for ipv4 / ipv6 ?

The "key" just creates a natural ordering in the tree, it's
almost arbitrary except that it must distribute well amongst
the entries.

I currently don't see any reason to make two trees right now.

> I dont understand how computing a 32bit key (sort of hash key) is going
> to help when hash collision happens, with an avl tree.
> Either version of tree (AVL/rbtree) will be expensive to use if depth is
> big (With 2 millions entries, depth is going to be very big). I
> understand you want to get rid of route cache ?

Do we plan to talk to 2 million unique destinations and have active
non-default metrics for each one of them very often?

inet_peer entries will only get created when we need to make
non-default metric settings for a specific destination address.

See that's the thing, it's scope is so much smaller than the existing
routing cache.  It's only going to be used in limited if not
controlled cases.

