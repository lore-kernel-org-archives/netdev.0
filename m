From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] icmp: add a global rate limitation
Date: Mon, 22 Sep 2014 16:09:04 -0400 (EDT)
Message-ID: <20140922.160904.1566383839759663411.davem@davemloft.net>
References: <1411137520.26859.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625AbaIVUJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:09:07 -0400
In-Reply-To: <1411137520.26859.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Sep 2014 07:38:40 -0700

> Current ICMP rate limiting uses inetpeer cache, which is an RBL tree
> protected by a lock, meaning that hosts can be stuck hard if all cpus
> want to check ICMP limits.

However, the replacement uses a single global spinlock for
synchronization.

 ...
> Note that if we really want to send millions of ICMP messages per
> second, we might extend idea and infra added in commit 04ca6973f7c1a
> ("ip: make IP identifiers less predictable") :
> add a token bucket in the ip_idents hash and no longer rely on inetpeer.

That would be preferred.

I don't really see how this patch makes things better.  The code goes
through a global spinlock unconditionally, and if it passes then it
looks up the inetpeer anyways.

I need more information to be convinced that this is an improvement
and that it actually solves the stated problem.  I'm sure you also
have some performance metrics to share, right? :-)
