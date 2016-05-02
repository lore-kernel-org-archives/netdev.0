From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] tipc: only process unicast on intended node
Date: Sun, 01 May 2016 21:04:00 -0400 (EDT)
Message-ID: <20160501.210400.667324864064886286.davem@davemloft.net>
References: <1461940824-20121-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	hamish.martin@alliedtelesis.co.nz
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbcEBBEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 21:04:04 -0400
In-Reply-To: <1461940824-20121-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 29 Apr 2016 10:40:24 -0400

> From: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
> 
> We have observed complete lock up of broadcast-link transmission due to
> unacknowledged packets never being removed from the 'transmq' queue. This
> is traced to nodes having their ack field set beyond the sequence number
> of packets that have actually been transmitted to them.
> Consider an example where node 1 has sent 10 packets to node 2 on a
> link and node 3 has sent 20 packets to node 2 on another link. We
> see examples of an ack from node 2 destined for node 3 being treated as
> an ack from node 2 at node 1. This leads to the ack on the node 1 to node
> 2 link being increased to 20 even though we have only sent 10 packets.
> When node 1 does get around to sending further packets, none of the
> packets with sequence numbers less than 21 are actually removed from the
> transmq.
> To resolve this we reinstate some code lost in commit d999297c3dbb ("tipc:
> reduce locking scope during packet reception") which ensures that only
> messages destined for the receiving node are processed by that node. This
> prevents the sequence numbers from getting out of sync and resolves the
> packet leakage, thereby resolving the broadcast-link transmission
> lock-ups we observed.
> 
> While we are aware that this change only patches over a root problem that
> we still haven't identified, this is a sanity test that it is always
> legitimate to do. It will remain in the code even after we identify and
> fix the real problem.
> 
> Reviewed-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
> Reviewed-by: John Thompson <john.thompson@alliedtelesis.co.nz>
> Signed-off-by: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
