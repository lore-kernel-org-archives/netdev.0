From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: metrics: Fix rcu-race when deleting
 multiple entries
Date: Wed, 22 Jan 2014 21:26:34 -0800 (PST)
Message-ID: <20140122.212634.1404913922893353238.davem@davemloft.net>
References: <1390307426-10840-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbaAWF0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:26:35 -0500
In-Reply-To: <1390307426-10840-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Tue, 21 Jan 2014 13:30:26 +0100

> In bbf852b96ebdc6d1 I introduced the tmlist, which allows to delete
> multiple entries from the cache that match a specified destination if no
> source-IP is specified.
> 
> However, as the cache is an RCU-list, we should not create this tmlist, as
> it will change the tcpm_next pointer of the element that will be deleted
> and so a thread iterating over the cache's entries while holding the
> RCU-lock might get "redirected" to this tmlist.
> 
> This patch fixes this, by reverting back to the old behavior prior to
> bbf852b96ebdc6d1, which means that we simply change the tcpm_next
> pointer of the previous element (pp) to jump over the one we are
> deleting.
> The difference is that we call kfree_rcu() directly on the cache entry,
> which allows us to delete multiple entries from the list.
> 
> Fixes: bbf852b96ebdc6d1 (tcp: metrics: Delete all entries matching a certain destination)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Looks good, applied, thank you.
