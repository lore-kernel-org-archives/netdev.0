From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: drop dst before queueing fragments
Date: Wed, 17 Apr 2013 01:15:40 -0400 (EDT)
Message-ID: <20130417.011540.1594987403341413760.davem@davemloft.net>
References: <1365702804.3887.180.camel@edumazet-glaptop>
	<20130416202022.GB2545@raven>
	<1366152941.3205.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tparkin@katalix.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab3DQFPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 01:15:44 -0400
In-Reply-To: <1366152941.3205.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Apr 2013 15:55:41 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 4a94445c9a5c (net: Use ip_route_input_noref() in input path)
> added a bug in IP defragmentation handling, as non refcounted
> dst could escape an RCU protected section.
> 
> Commit 64f3b9e203bd068 (net: ip_expire() must revalidate route) fixed
> the case of timeouts, but not the general problem.
> 
> Tom Parkin noticed crashes in UDP stack and provided a patch,
> but further analysis permitted us to pinpoint the root cause.
> 
> Before queueing a packet into a frag list, we must drop its dst,
> as this dst has limited lifetime (RCU protected)
> 
> When/if a packet is finally reassembled, we use the dst of the very
> last skb, still protected by RCU and valid, as the dst of the
> reassembled packet.
> 
> Use same logic in IPv6, as there is no need to hold dst references.
> 
> Reported-by: Tom Parkin <tparkin@katalix.com>
> Tested-by: Tom Parkin <tparkin@katalix.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
