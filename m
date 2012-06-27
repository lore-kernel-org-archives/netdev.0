From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 09:24:05 +0200
Message-ID: <1340781845.2028.133.camel@localhost>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
	 <1340778733.2028.110.camel@localhost>
	 <20120626.235423.588696200884989114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756300Ab2F0HYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 03:24:16 -0400
In-Reply-To: <20120626.235423.588696200884989114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 23:54 -0700, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Wed, 27 Jun 2012 08:32:13 +0200
> 
> > Using it as default, might be "dangerous" and open an attack vector
> > on SYN cookies in Linux.
> 
> If it's dangerous for syncookies then it's just as dangerous for
> the routing hash and the socket hashes where we use it already.
> 
> Therefore, this sounds like a baseless claim to me.

Yes, you are right. Looking at you patch again, you also use
syncookie_secret[c] as initval.  So, it should be safe.

But, I still believe that we need, to solve this SYN issues by parallel
processing of packets. (It seems Eric and Hans are looking at a single
core SYN processing scheme, but I might have missed their point).
