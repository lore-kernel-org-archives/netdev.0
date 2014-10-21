From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix a potential deadlock
Date: Tue, 21 Oct 2014 15:30:13 -0400 (EDT)
Message-ID: <20141021.153013.950822619392700910.davem@davemloft.net>
References: <1413787465-14600-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755060AbaJUTaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 15:30:17 -0400
In-Reply-To: <1413787465-14600-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 20 Oct 2014 14:44:25 +0800

> Locking dependency detected below possible unsafe locking scenario:
> 
>            CPU0                          CPU1
> T0:  tipc_named_rcv()                tipc_rcv()
> T1:  [grab nametble write lock]*     [grab node lock]*
> T2:  tipc_update_nametbl()           tipc_node_link_up()
> T3:  tipc_nodesub_subscribe()        tipc_nametbl_publish()
> T4:  [grab node lock]*               [grab nametble write lock]*
> 
> The opposite order of holding nametbl write lock and node lock on
> above two different paths may result in a deadlock. If we move the
> the updating of the name table after link state named out of node
> lock, the reverse order of holding locks will be eliminated, and
> as a result, the deadlock risk.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
