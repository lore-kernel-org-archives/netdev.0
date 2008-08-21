From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 03:05:23 -0700 (PDT)
Message-ID: <20080821.030523.205239441.davem@davemloft.net>
References: <20080819085504.GB29038@gondor.apana.org.au>
	<20080819091642.GI4376@ff.dom.local>
	<20080821100155.GA3621@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753009AbYHUKFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 06:05:24 -0400
In-Reply-To: <20080821100155.GA3621@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 21 Aug 2008 10:01:55 +0000

> If we do this with child qdisc from qdisc_graft() it's without
> deactivation. The rest of the tree can be dequeued in the meantime
> and call qdisc_tree_decrease_qlen() (like hfsc, tbf, netem), which
> uses qdisc_lookup() to access this list. We list_del() under rtnl
> lock only, they lookup under sch_tree_lock(). Is it a bit unsafe
> or I miss something?

They hold RTNL as well.

Remember, sch_tree_lock() uses qdisc_root_lock() which as I've
told you at least twice now asserts that RTNL is held :-)
