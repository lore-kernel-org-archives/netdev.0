From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 00:03:07 -0700 (PDT)
Message-ID: <20080819.000307.71415459.davem@davemloft.net>
References: <20080818.171124.192743795.davem@davemloft.net>
	<20080818.210701.80578862.davem@davemloft.net>
	<20080819064609.GA4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56799
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751477AbYHSHDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:03:08 -0400
In-Reply-To: <20080819064609.GA4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 19 Aug 2008 06:46:09 +0000

> Actually, I, and earlier Herbert, have written about destroying root
> qdiscs without sch_tree_lock(). I don't know how Herbert, but I'd
> prefer to leave here this lock for child qdiscs: they can remove some
> common structures, so this needs more checking, and even if they don't
> do this currently, there is no need to remove this possibility here.
> Similarly, I'm not sure if removing BH protection is really needed
> here.

Well you don't really know if this happens or not for sure
do you? :-)

Why don't you go make sure of this and report back what you
find?  I see no reason to account for something that cannot
happen.

It's better to have a consistent rule for qdisc_destroy()
rather than a bunch of special cases that are hard to audit.
