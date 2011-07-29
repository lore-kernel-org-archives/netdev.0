From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 08:19:02 -0700 (PDT)
Message-ID: <20110729.081902.300678107767426313.davem@davemloft.net>
References: <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4E32C76B.5010700@hippy.csoma.elte.hu>
	<1311952306.2843.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: synapse@hippy.csoma.elte.hu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab1G2PTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 11:19:11 -0400
In-Reply-To: <1311952306.2843.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jul 2011 17:11:46 +0200

> Thats tricky, because I am not sure we dont need RCU protection since we
> can now exchange dst neighbour on the fly.
> 
> Following patch would only reduce the window of bug, not a complete
> fix...
> 
> David, any opinion on this ?

Indeed, old code worked because we invalidated entire route cache
entry, and we never before ran arp_bind_neighbour() except on new
route cache entires before they become globally visible.

I think when we change an existing neigh we will need to release old
neigh via RCU, at a minimum.
