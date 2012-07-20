From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: improve latencies of timer triggered
 events
Date: Fri, 20 Jul 2012 11:01:28 -0700 (PDT)
Message-ID: <20120720.110128.205223157733612873.davem@davemloft.net>
References: <1342799150.2626.7574.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ycheng@google.com,
	ncardwell@google.com, nanditad@google.com, johnwheffner@gmail.com,
	hkchu@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab2GTSB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:01:28 -0400
In-Reply-To: <1342799150.2626.7574.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jul 2012 17:45:50 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Modern TCP stack highly depends on tcp_write_timer() having a small
> latency, but current implementation doesn't exactly meet the
> expectations.
> 
> When a timer fires but finds the socket is owned by the user, it rearms
> itself for an additional delay hoping next run will be more
> successful.
> 
> tcp_write_timer() for example uses a 50ms delay for next try, and it
> defeats many attempts to get predictable TCP behavior in term of
> latencies.
> 
> Use the recently introduced tcp_release_cb(), so that the user owning
> the socket will call various handlers right before socket release.
> 
> This will permit us to post a followup patch to address the
> tcp_tso_should_defer() syndrome (some deferred packets have to wait
> RTO timer to be transmitted, while cwnd should allow us to send them
> sooner)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I like this a lot, applied, thanks Eric.
