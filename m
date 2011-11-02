From: David Miller <davem@davemloft.net>
Subject: Re: ARP garbage collection issues in 3.1?
Date: Wed, 02 Nov 2011 00:48:20 -0400 (EDT)
Message-ID: <20111102.004820.1600243559959513379.davem@davemloft.net>
References: <20111102153443.38cc1e5c@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948Ab1KBEs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 00:48:26 -0400
In-Reply-To: <20111102153443.38cc1e5c@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Wed, 2 Nov 2011 15:34:43 +1100

> Any ideas how we could make this behave a bit better? I know setting
> gc_thresh3 higher is the ultimate solution, but if gc_thresh1 and
> gc_thresh2 are always below the route threshold we should either fix
> this issue or remove them completely.

The solution is to do refcount'less RCU lookups into the neigh
tables on every packet send, and long term that's what I intend
to implement.

That's what's behind making the recent change to make the ARP hash
cheaper etc.

See slides 5, 6, and 7 in:

http://vger.kernel.org/netconf2011_slides/davem_netconf2011.pdf

Once that's done you can trim whatever neigh entries you want,
whenever you want.

You are right that the current situation is silly, because if
we're willing to commit to N routing table entries we might as
well be willing to commit to N arp table entries as well.
