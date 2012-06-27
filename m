From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 15:23:53 -0700 (PDT)
Message-ID: <20120627.152353.771450388391058676.davem@davemloft.net>
References: <20120626.235423.588696200884989114.davem@davemloft.net>
	<20120627195032.GI1269@breakpoint.cc>
	<1340833160.26242.176.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, brouer@redhat.com, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756219Ab2F0WXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:23:53 -0400
In-Reply-To: <1340833160.26242.176.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Jun 2012 23:39:20 +0200

> On Wed, 2012-06-27 at 21:50 +0200, Florian Westphal wrote:
> 
>> I doubt using jhash is safe for syncookies.
>> 
>> There a several differences to other uses in kernel:
>> - all hash input except u32 cookie_secret[2] is known
>> - we transmit hash result (i.e, its visible to 3rd party)
>> - we do not re-seed the secret, ever
>> 
>> it should be quite easy to recompute cookie_secret[] from known syncookie
>> values?
> 
> We could re-seed the secrets every MSL seconds a bit like in
> tcp_cookie_generator()
> 
> This would require check_tcp_syn_cookie() doing two checks (most recent
> seed, and previous one if first check failed)

That could help, but I'm leaning towards not doing this at all.  Like
for the normal sequence number generation we really can't do this.
