From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pktgen: speedup fragmented skbs
Date: Tue, 25 Jan 2011 13:26:26 -0800 (PST)
Message-ID: <20110125.132626.39178379.davem@davemloft.net>
References: <1295975635.3588.337.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753850Ab1AYVZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 16:25:51 -0500
In-Reply-To: <1295975635.3588.337.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Jan 2011 18:13:55 +0100

> We spend lot of time clearing pages in pktgen.
> (Or not clearing them on ipv6 and leaking kernel memory)
> 
> Since we dont modify them, we can use one zeroed page, and get
> references on it. This page can use NUMA affinity as well.
> 
> Define pktgen_finalize_skb() helper, used both in ipv4 and ipv6
> 
> Results using skbs with one frag :
> 
> Before patch :
> 
> Result: OK: 608980458(c608978520+d1938) nsec, 1000000000
> (100byte,1frags)
>   1642088pps 1313Mb/sec (1313670400bps) errors: 0
> 
> After patch :
> 
> Result: OK: 345285014(c345283891+d1123) nsec, 1000000000
> (100byte,1frags)
>   2896158pps 2316Mb/sec (2316926400bps) errors: 0
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, although I changed "->page = 0;" to "->page = NULL;"

Thanks!
