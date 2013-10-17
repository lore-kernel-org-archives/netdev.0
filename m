From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: remove the sk_can_gso() check from
 tcp_set_skb_tso_segs()
Date: Thu, 17 Oct 2013 16:09:07 -0400 (EDT)
Message-ID: <20131017.160907.2106635631584412215.davem@davemloft.net>
References: <1381865094.2045.69.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759409Ab3JQUJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:09:09 -0400
In-Reply-To: <1381865094.2045.69.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Oct 2013 12:24:54 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> sk_can_gso() should only be used as a hint in tcp_sendmsg() to build GSO
> packets in the first place. (As a performance hint)
> 
> Once we have GSO packets in write queue, we can not decide they are no
> longer GSO only because flow now uses a route which doesn't handle
> TSO/GSO.
> 
> Core networking stack handles the case very well for us, all we need
> is keeping track of packet counts in MSS terms, regardless of
> segmentation done later (in GSO or hardware)
> 
> Right now, if  tcp_fragment() splits a GSO packet in two parts,
> @left and @right, and route changed through a non GSO device,
> both @left and @right have pcount set to 1, which is wrong,
> and leads to incorrect packet_count tracking.
> 
> This problem was added in commit d5ac99a648 ("[TCP]: skb pcount with MTU
> discovery")
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Also applied and queued up for -stable, thanks everyone.
