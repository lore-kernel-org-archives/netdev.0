From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] tcp: defer shinfo->gso_size|type settings
Date: Thu, 11 Jun 2015 16:45:02 -0700 (PDT)
Message-ID: <20150611.164502.578119775073363894.davem@davemloft.net>
References: <1434039319-31309-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	edumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbbFKXpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 19:45:04 -0400
In-Reply-To: <1434039319-31309-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 11 Jun 2015 09:15:14 -0700

> We put shinfo->gso_segs in TCP_SKB_CB(skb) a while back for performance
> reasons.
> 
> This was in commit cd7d8498c9a5 ("tcp: change tcp_skb_pcount() location")
> 
> This patch series complete the job for gso_size and gso_type, so that
> we do not bring 2 extra cache lines in tcp write xmit fast path,
> and making tcp_init_tso_segs() simpler and faster.

Series applied, however long term I worry that using a u16 will not
work with TSO'd ipv6 jumbograms.
