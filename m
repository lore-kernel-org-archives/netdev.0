From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Thu, 13 Oct 2011 13:58:08 -0400 (EDT)
Message-ID: <20111013.135808.636341622629050648.davem@davemloft.net>
References: <20111011110922.GD1830@secunet.com>
	<20111012.170218.279202034199478303.davem@davemloft.net>
	<20111013100950.GO1830@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44329 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263Ab1JMR6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 13:58:19 -0400
In-Reply-To: <20111013100950.GO1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 13 Oct 2011 12:09:50 +0200

> At least it seems that raw_sendmsg() and ping_sendmsg() don't use
> a cached route, they do the route lookup in any case. I don't see
> where we check if we learned a new pmtu in this cases. 

A freshly looked up route should not have ->obsolete set.

That's why we don't do dst_check() in that part of the ip_output.c
helper code you're modifying.

Please find out exactly why dst->obsolete is non-zero on a freshly
looked up route.  It's unexpected.
