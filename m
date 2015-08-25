From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: fix slow start after idle vs TSO/GSO
Date: Tue, 25 Aug 2015 11:23:19 -0700 (PDT)
Message-ID: <20150825.112319.941840654581719226.davem@davemloft.net>
References: <1440090487.6610.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<1440185400.6610.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393AbbHYSXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:23:20 -0400
In-Reply-To: <1440185400.6610.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Aug 2015 12:30:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> slow start after idle might reduce cwnd, but we perform this
> after first packet was cooked and sent.
> 
> With TSO/GSO, it means that we might send a full TSO packet
> even if cwnd should have been reduced to IW10.
> 
> Moving the SSAI check in skb_entail() makes sense, because
> we slightly reduce number of times this check is done,
> especially for large send() and TCP Small queue callbacks from
> softirq context.
> 
> As Neal pointed out, we also need to perform the check
> if/when receive window opens.
> 
> Tested:
> 
> Following packetdrill test demonstrates the problem
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
