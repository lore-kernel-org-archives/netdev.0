From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 03/06]: Fix endless loops caused by inaccurate qlen
 counters (part 1)
Date: Wed, 29 Nov 2006 17:35:59 -0800 (PST)
Message-ID: <20061129.173559.130238620.davem@davemloft.net>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
	<20061120130840.22347.54563.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53223
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967803AbWK3BgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:36:01 -0500
To: kaber@trash.net
In-Reply-To: <20061120130840.22347.54563.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 20 Nov 2006 14:08:41 +0100 (MET)

> [NET_SCHED]: Fix endless loops caused by inaccurate qlen counters (part 1)
> 
> There are multiple problems related to qlen adjustment that can lead
> to an upper qdisc getting out of sync with the real number of packets
> queued, leading to endless dequeueing attempts by the upper layer code.
> 
> All qdiscs must maintain an accurate q.qlen counter. There are basically
> two groups of operations affecting the qlen: operations that propagate
> down the tree (enqueue, dequeue, requeue, drop, reset) beginning at the
> root qdisc and operations only affecting a subtree or single qdisc
> (change, graft, delete class). Since qlen changes during operations from
> the second group don't propagate to ancestor qdiscs, their qlen values
> become desynchronized.
> 
> This patch adds a function to propagate qlen changes up the qdisc tree,
> optionally calling a callback function to perform qdisc-internal
> maintenance when the child qdisc becomes empty. The follow-up patches
> will convert all qdiscs to use this function where necessary.
> 
> Noticed by Timo Steinbach <tsteinbach@astaro.com>.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.20, thanks a lot.
