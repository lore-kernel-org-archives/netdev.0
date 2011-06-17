From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: fix starving rx ring when alloc_skb fails
Date: Fri, 17 Jun 2011 12:09:00 -0400 (EDT)
Message-ID: <20110617.120900.550060204741705506.davem@davemloft.net>
References: <03E840D17E263A48A5766AD576E0423A012911782E@exch-mbx-111.vmware.com>
	<20110617.005356.180809929241094878.davem@davemloft.net>
	<1308312860.11457.56.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: scottjg@vmware.com, netdev@vger.kernel.org, pv-drivers@vmware.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759383Ab1FQQJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 12:09:46 -0400
In-Reply-To: <1308312860.11457.56.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 17 Jun 2011 13:14:20 +0100

> But this means the driver drops received packets as soon as there is an
> allocation failure, rather than only if there are repeated failures.  I
> don't see how that's preferable.

Because it decreases the possibility of RX ring starvation.

If you get one allocation failure during a NAPI poll run, and you're
proabably processing a set of packets, they are all going to fail.
