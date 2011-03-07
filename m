From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] fib semantic matching
Date: Mon, 07 Mar 2011 15:13:33 -0800 (PST)
Message-ID: <20110307.151333.15237352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35652
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756385Ab1CGXM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:12:56 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EF42624C089
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2011 15:13:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fib_semantic_match() creates unnecessary overhead on route lookups
for two reasons:

1) It does type validation at run time instead of when we insert
   the route.

2) Argument passing is expensive because it does it's work as
   a seperate function.

So these two patches move type validation into fib_create_info(),
and then we inline fib_semantic_match() completely into check_leaf().

This is good for 50+ cycle gain on output route lookups on Niagara2.

Signed-off-by: David S. Miller <davem@davemloft.net>
