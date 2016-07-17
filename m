From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: bridge: simplify receive path and
 consolidate forwarding paths
Date: Sat, 16 Jul 2016 19:58:02 -0700 (PDT)
Message-ID: <20160716.195802.931580320600384868.davem@davemloft.net>
References: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbcGQC6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 22:58:06 -0400
In-Reply-To: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 14 Jul 2016 06:09:58 +0300

> This set tries to simplify the receive and forwarding paths. Patch 01 is
> a trivial style adjustment, patch 02 removes one conditional from the
> unicast fast path, patch 03 removes another conditional and more imporantly
> removes the skb0/skb2 ambiguity about locally receiving the skb and
> switches to a boolean called "local_rcv".
> Patch 04 is the most important change which consolidates the forwarding
> paths for locally originated and forwarded packets into __br_forward. This
> allows us to remove the function pointers giving a minor performance boost,
> more importantly it makes it much easier to reason about the forwarding
> path and reduces the code duplication that was needed when making changes.
> Also it allows the receive path to fully setup the environment prior to
> calling any forwarding functions (i.e. to properly set unicast, local_rcv
> and search for unicast/mcast dst).
> Functionally everything should stay the same after this set.
> 
> I've done basic tests with unicast/multicast/broadcast Tx/Rx. Please
> review carefully.

I've reviewed this twice and can't find any problems, so applied to
net-next, thanks.
