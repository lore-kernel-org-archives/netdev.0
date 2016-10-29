From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix broadcast link synchronization
 problem
Date: Sat, 29 Oct 2016 17:21:51 -0400 (EDT)
Message-ID: <20161029.172151.2096765504289435592.davem@davemloft.net>
References: <1477608715-28003-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53102 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbcJ2VVx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 17:21:53 -0400
In-Reply-To: <1477608715-28003-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 27 Oct 2016 18:51:55 -0400

> In commit 2d18ac4ba745 ("tipc: extend broadcast link initialization
> criteria") we tried to fix a problem with the initial synchronization
> of broadcast link acknowledge values. Unfortunately that solution is
> not sufficient to solve the issue.
> 
> We have seen it happen that LINK_PROTOCOL/STATE packets with a valid
> non-zero unicast acknowledge number may bypass BCAST_PROTOCOL
> initialization, NAME_DISTRIBUTOR and other STATE packets with invalid
> broadcast acknowledge numbers, leading to premature opening of the
> broadcast link. When the bypassed packets finally arrive, they are
> inadvertently accepted, and the already correctly initialized
> acknowledge number in the broadcast receive link is overwritten by
> the invalid (zero) value of the said packets. After this the broadcast
> link goes stale.
> 
> We now fix this by marking the packets where we know the acknowledge
> value is or may be invalid, and then ignoring the acks from those.
> 
> To this purpose, we claim an unused bit in the header to indicate that
> the value is invalid. We set the bit to 1 in the initial BCAST_PROTOCOL
> synchronization packet and all initial ("bulk") NAME_DISTRIBUTOR
> packets, plus those LINK_PROTOCOL packets sent out before the broadcast
> links are fully synchronized.
> 
> This minor protocol update is fully backwards compatible.
> 
> Reported-by: John Thompson <thompa.atl@gmail.com>
> Tested-by: John Thompson <thompa.atl@gmail.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
