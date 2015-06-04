From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to
 processes context
Date: Thu, 04 Jun 2015 11:48:16 -0700 (PDT)
Message-ID: <20150604.114816.405065923499742451.davem@davemloft.net>
References: <20150604.013409.228829580818256337.davem@davemloft.net>
	<20150604090749.GA18460@verge.net.au>
	<5570701A.5010903@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp
To: toshiaki.makita1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbbFDSsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 14:48:18 -0400
In-Reply-To: <5570701A.5010903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Date: Fri, 05 Jun 2015 00:34:50 +0900

> I'm thinking IRQ context does not match the prepare-commit model, and
> Scott's fix is needed. There are more critical problems Scott's patch
> fixes.
> (I shortly explained it before, although it is not clearly stated in
> the commitlog. http://marc.info/?l=linux-netdev&m=143219842420093&w=2)
> 
> 1. Operations from IRQ context could change the state of rocker, like
> hash tables. This could cause inconsistent states between
> prepare-commit (for example, prepare phase cannot find an entry but
> commit phase can find it), and leads to memory corruption (unreserved
> memory could be used or reserved memory could not be used in commit
> phase).

If you hold the spinlock across the prepare and commit operation there
is no problem.

It is exactly what I am suggesting and fixes all the bugs.

You add ->transaction_begin() and ->transaction_end() and these take
the driver's spinlock or whatever synchronization object to protect
the transaction.

Then there is no conflict between software interrupt based operations
and RTNL mutex held ones.

I'm not going to explain my preference for how to fix this any further
and will ignore any further submissions of a patch that tries to do
this by pushing things to a workqueue, sorry.
