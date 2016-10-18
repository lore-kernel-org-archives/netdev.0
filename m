From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bridge: multicast: restore perm router ports on
 multicast enable
Date: Tue, 18 Oct 2016 13:53:18 -0400 (EDT)
Message-ID: <20161018.135318.135800310588412434.davem@davemloft.net>
References: <1476796238-9384-1-git-send-email-nikolay@cumulusnetworks.com>
        <1476806988-20557-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sashok@cumulusnetworks.com,
        roopa@cumulusnetworks.com, herbert@gondor.apana.org.au,
        stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034146AbcJRRxY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 13:53:24 -0400
In-Reply-To: <1476806988-20557-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue, 18 Oct 2016 18:09:48 +0200

> Satish reported a problem with the perm multicast router ports not getting
> reenabled after some series of events, in particular if it happens that the
> multicast snooping has been disabled and the port goes to disabled state
> then it will be deleted from the router port list, but if it moves into
> non-disabled state it will not be re-added because the mcast snooping is
> still disabled, and enabling snooping later does nothing.
> 
> Here are the steps to reproduce, setup br0 with snooping enabled and eth1
> added as a perm router (multicast_router = 2):
> 1. $ echo 0 > /sys/class/net/br0/bridge/multicast_snooping
> 2. $ ip l set eth1 down
> ^ This step deletes the interface from the router list
> 3. $ ip l set eth1 up
> ^ This step does not add it again because mcast snooping is disabled
> 4. $ echo 1 > /sys/class/net/br0/bridge/multicast_snooping
> 5. $ bridge -d -s mdb show
> <empty>
> 
> At this point we have mcast enabled and eth1 as a perm router (value = 2)
> but it is not in the router list which is incorrect.
> 
> After this change:
> 1. $ echo 0 > /sys/class/net/br0/bridge/multicast_snooping
> 2. $ ip l set eth1 down
> ^ This step deletes the interface from the router list
> 3. $ ip l set eth1 up
> ^ This step does not add it again because mcast snooping is disabled
> 4. $ echo 1 > /sys/class/net/br0/bridge/multicast_snooping
> 5. $ bridge -d -s mdb show
> router ports on br0: eth1
> 
> Note: we can directly do br_multicast_enable_port for all because the
> querier timer already has checks for the port state and will simply
> expire if it's in blocking/disabled. See the comment added by
> commit 9aa66382163e7 ("bridge: multicast: add a comment to
> br_port_state_selection about blocking state")
> 
> Fixes: 561f1103a2b7 ("bridge: Add multicast_snooping sysfs toggle")
> Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable, thanks!
