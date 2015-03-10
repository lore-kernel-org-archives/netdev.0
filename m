From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: ensure that idle links are deleted
 when a bearer is disabled
Date: Tue, 10 Mar 2015 18:38:01 -0400 (EDT)
Message-ID: <20150310.183801.1545885202549602206.davem@davemloft.net>
References: <1426004614-18168-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbbCJWiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 18:38:03 -0400
In-Reply-To: <1426004614-18168-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 10 Mar 2015 12:23:34 -0400

> commit afaa3f65f65fda2e7b190aac7e2a75d9a2a77cb6
> (tipc: purge links when bearer is disabled) was an attempt to resolve
> a problem that turned out to have a more profound reason.
> 
> When we disable a bearer, we delete all its pertaining links if
> there is no other bearer to perform failover to, or if the module
> is shutting down. In case there are dual bearers, we wait with
> deleting links until the failover procedure is finished.
> 
> However, this misses the case when a link on the removed bearer
> was already down, so that there will be no failover procedure to
> finish the link delete. This causes confusion if a new bearer is
> added to replace the removed one, and also entails a small memory
> leak.
> 
> This commit takes the current state of the link into account when
> deciding when to delete it, and also reverses the above-mentioned
> commit.
> 
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thank you.
