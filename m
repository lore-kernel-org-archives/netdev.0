From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: do not send too big packets at retransmit time
Date: Wed, 29 Jun 2016 05:26:17 -0400 (EDT)
Message-ID: <20160629.052617.632863831347001831.davem@davemloft.net>
References: <CADVnQynZxphzi37PD6GRV6k=tgjHfH2HuL7GiGVjOSMOCLSOcA@mail.gmail.com>
	<1467034072.6850.152.camel@edumazet-glaptop3.roam.corp.google.com>
	<1467041930.6850.166.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, arjun@chelsio.com, edumazet@google.com,
	netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com,
	kumaras@chelsio.com, santosh@chelsio.com, nirranjan@chelsio.com,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbcF2J0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 05:26:48 -0400
In-Reply-To: <1467041930.6850.166.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Jun 2016 17:38:50 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Arjun reported a bug in TCP stack and bisected it to a recent commit.
> 
> In case where we process SACK, we can coalesce multiple skbs
> into fat ones (tcp_shift_skb_data()), to lower write queue
> overhead, because we do not expect to retransmit these packets.
> 
> However, SACK reneging can happen, forcing the sender to retransmit
> all these packets. If skb->len is above 64KB, we then send buggy
> IP packets that could hang TSO engine on cxgb4.
> 
> Neal suggested to use tcp_tso_autosize() instead of tp->gso_segs
> so that we cook packets of optimal size vs TCP/pacing.
> 
> Thanks to Arjun for reporting the bug and running the tests !
> 
> Fixes: 10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Arjun V <arjun@chelsio.com>
> Tested-by: Arjun V <arjun@chelsio.com>

Applied.
