From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: make sure skb is not shared before using
 skb_get()
Date: Fri, 13 Feb 2015 07:12:13 -0800 (PST)
Message-ID: <20150213.071213.1105639128565896413.davem@davemloft.net>
References: <1423831632.4942.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbbBMPFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 10:05:09 -0500
In-Reply-To: <1423831632.4942.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Feb 2015 04:47:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> IPv6 can keep a copy of SYN message using skb_get() in
> tcp_v6_conn_request() so that caller wont free the skb when calling
> kfree_skb() later.
>     
> Therefore TCP fast open has to clone the skb it is queuing in
> child->sk_receive_queue, as all skbs consumed from receive_queue are
> freed using __kfree_skb() (ie assuming skb->users == 1)
>     
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Fixes: 5b7ed0892f2af ("tcp: move fastopen functions to tcp_fastopen.c")

Applied, thanks.
