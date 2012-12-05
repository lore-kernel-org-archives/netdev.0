From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next] ipv6: avoid taking locks at socket dismantle
Date: Wed, 5 Dec 2012 16:07:16 -0500
Message-ID: <OF525F8BC1.196D90F1-ON85257ACB.0073BE61-85257ACB.007403D3@us.ibm.com>
References: <1354735090.31222.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:39352 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754305Ab2LEVH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 16:07:57 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 5 Dec 2012 16:07:56 -0500
In-Reply-To: <1354735090.31222.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Eric Dumazet <edumazet@google.com>
> 
> ipv6_sock_mc_close() is called for ipv6 sockets at close time, and most
> of them don't use multicast.
> 
> Add a test to avoid contention on a shared spinlock.
> 
> Same heuristic applies for ipv6_sock_ac_close(), to avoid contention
> on a shared rwlock.

        What prevents a different thread from racing with the
tests for NULL on these?

                                                +-DLS
