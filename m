From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Tue, 10 Jul 2012 22:44:35 -0700 (PDT)
Message-ID: <20120710.224435.269512781698609358.davem@davemloft.net>
References: <1341979678.3265.6660.camel@edumazet-glaptop>
	<20120710.211304.1112522544390324120.davem@davemloft.net>
	<1341981861.3265.6740.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab2GKFoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 01:44:38 -0400
In-Reply-To: <1341981861.3265.6740.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Jul 2012 06:44:21 +0200

> I dont see where in demux code we have a 64bit access ?

Oh I see, we only do it in the socket, sigh.

#define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
	 ((*((__addrpair *)&(inet_sk(__sk)->inet_daddr))) == (__cookie))  &&	\
	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports))   &&	\
 ...
