From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Mon, 14 Mar 2011 14:25:20 -0700 (PDT)
Message-ID: <20110314.142520.28811818.davem@davemloft.net>
References: <1300137299-28161-1-git-send-email-msmith@cbnco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msmith@cbnco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753008Ab1CNVYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:24:42 -0400
In-Reply-To: <1300137299-28161-1-git-send-email-msmith@cbnco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Smith <msmith@cbnco.com>
Date: Mon, 14 Mar 2011 17:14:59 -0400

> The reverse path filter interferes with IPsec subnet-to-subnet tunnels,
> especially when the link to the IPsec peer is on an interface other than
> the one hosting the default route.
> 
> With dynamic routing, where the peer might be reachable through eth0
> today and eth1 tomorrow, it's difficult to keep rp_filter enabled unless
> fake routes to the remote subnets are configured on the interface
> currently used to reach the peer.
> 
> IPsec provides a much stronger anti-spoofing policy than rp_filter, so
> this patch disables the rp_filter for packets with a security path.
> 
> Signed-off-by: Michael Smith <msmith@cbnco.com>

First, I'm only willing to accept a patch like this to net-next-2.6
for which all of the code you are changing is radically different.

Secondly, fib_validate_source() already takes too many damn arguments.
Find another, less costly, way to pass this information down there.

Frankly, I think RPF should be disabled completely by default.  When
it doesn't do anything useful, it's making route lookups twice as
expensive as they need to be.
