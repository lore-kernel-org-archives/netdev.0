From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc list locking
Date: Fri, 22 Aug 2008 03:23:32 -0700 (PDT)
Message-ID: <20080822.032332.127607587.davem@davemloft.net>
References: <20080821204052.GB2665@ami.dom.local>
	<20080821222446.GF14521@gondor.apana.org.au>
	<20080822092729.GA14729@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753339AbYHVKXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 06:23:34 -0400
In-Reply-To: <20080822092729.GA14729@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 22 Aug 2008 09:27:30 +0000

> pkt_sched: Fix qdisc list locking
> 
> Since some qdiscs call qdisc_tree_decrease_qlen() (so qdisc_lookup())
> without rtnl_lock(), adding and deleting from a qdisc list needs
> additional locking. This patch adds global spinlock qdisc_list_lock
> and wrapper functions for modifying the list. It is considered as a
> temporary solution until hfsc_dequeue(), netem_dequeue() and
> tbf_dequeue() (or qdisc_tree_decrease_qlen()) are redone.
> 
> With feedback from Herbert Xu and David S. Miller.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Looks good Jarek, thanks!

Since these requeue failure cases are slow paths, this shouldn't have
any performance impact either.

I'll apply this, thanks!
