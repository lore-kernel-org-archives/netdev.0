From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: gso: fix truesize tracking
Date: Mon, 28 Oct 2013 00:58:35 -0400 (EDT)
Message-ID: <20131028.005835.2085407982365928314.davem@davemloft.net>
References: <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	<1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
	<1382747177.4032.21.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab3J1E6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 00:58:36 -0400
In-Reply-To: <1382747177.4032.21.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Oct 2013 17:26:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 6ff50cd55545 ("tcp: gso: do not generate out of order packets")
> had an heuristic that can trigger a warning in skb_try_coalesce(),
> because skb->truesize of the gso segments were exactly set to mss.
> 
> This breaks the requirement that
> 
> skb->truesize >= skb->len + truesizeof(struct sk_buff);
> 
> It can trivially be reproduced by :
> 
> ifconfig lo mtu 1500
> ethtool -K lo tso off
> netperf
> 
> As the skbs are looped into the TCP networking stack, skb_try_coalesce()
> warns us of these skb under-estimating their truesize.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> Based on net-next but applies as well on net tree with some fuzz.
> 
> David, we might backport this one to 3.12 and stable later, I let you
> decide.

I'm still thinking about what to do with this one.
