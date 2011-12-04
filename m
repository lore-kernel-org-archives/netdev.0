From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: take care of misalignments
Date: Sun, 04 Dec 2011 13:21:26 -0500 (EST)
Message-ID: <20111204.132126.654109006321344175.davem@davemloft.net>
References: <20111202.163024.1294014889349291295.davem@davemloft.net>
	<1322924992.2762.117.camel@edumazet-laptop>
	<1322984393.2762.134.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab1LDSVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 13:21:30 -0500
In-Reply-To: <1322984393.2762.134.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 04 Dec 2011 08:39:53 +0100

> [PATCH] tcp: take care of misalignments
> 
> We discovered that TCP stack could retransmit misaligned skbs if a
> malicious peer acknowledged sub MSS frame. This currently can happen
> only if output interface is non SG enabled : If SG is enabled, tcp
> builds headless skbs (all payload is included in fragments), so the tcp
> trimming process only removes parts of skb fragments, header stay
> aligned.
> 
> Some arches cant handle misalignments, so force a head reallocation and
> shrink headroom to MAX_TCP_HEADER.
> 
> Dont care about misaligments on x86 and PPC (or other arches setting
> NET_IP_ALIGN to 0)
> 
> This patch introduces __pskb_copy() which can specify the headroom of
> new head, and pskb_copy() becomes a wrapper on top of __pskb_copy()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, applied.
