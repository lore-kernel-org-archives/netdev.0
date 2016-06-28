From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Tue, 28 Jun 2016 04:20:31 -0400 (EDT)
Message-ID: <20160628.042031.1126927454365803661.davem@davemloft.net>
References: <10542.1466716851@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, veli-matti.lintu@opinsys.fi,
	vfalico@gmail.com, gospo@cumulusnetworks.com, zyjzyj2000@gmail.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbcF1IV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 04:21:29 -0400
In-Reply-To: <10542.1466716851@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Thu, 23 Jun 2016 14:20:51 -0700

> 
> 	Since commit 7bb11dc9f59d ("bonding: unify all places where
> actor-oper key needs to be updated."), the logic in bonding to handle
> selection between multiple aggregators has not functioned.
> 
> 	This affects only configurations wherein the bonding slaves
> connect to two discrete aggregators (e.g., two independent switches, each
> with LACP enabled), thus creating two separate aggregation groups within a
> single bond.
> 
> 	The cause is a change in 7bb11dc9f59d to no longer set
> AD_PORT_BEGIN on a port after a link state change, which would cause the
> port to be reselected for attachment to an aggregator as if were newly
> added to the bond.  We cannot restore the prior behavior, as it
> contradicts IEEE 802.1AX 5.4.12, which requires ports that "become
> inoperable" (lose carrier, setting port_enabled=false as per 802.1AX
> 5.4.7) to remain selected (i.e., assigned to the aggregator).  As the port
> now remains selected, the aggregator selection logic is not invoked.
> 
> 	A side effect of this change is that aggregators in bonding will
> now contain ports that are link down.  The aggregator selection logic
> does not currently handle this situation correctly, causing incorrect
> aggregator selection.
> 
> 	This patch makes two changes to repair the aggregator selection
> logic in bonding to function as documented and within the confines of the
> standard:
> 
> 	First, the aggregator selection and related logic now utilizes the
> number of active ports per aggregator, not the number of selected ports
> (as some selected ports may be down).  The ad_select "bandwidth" and
> "count" options only consider ports that are link up.
> 
> 	Second, on any carrier state change of any slave, the aggregator
> selection logic is explicitly called to insure the correct aggregator is
> active.
> 
> Reported-by: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
> Fixes: 7bb11dc9f59d ("bonding: unify all places where actor-oper key needs to be updated.")
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

Applied and queued up for -stable, thanks Jay.
