From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 5/5] net:stmmac: asynchronous tx_clean
Date: Mon, 21 Oct 2013 11:24:36 -0700
Message-ID: <1382379876.3284.76.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
	  <1381937052-8999-6-git-send-email-jimmy.perchet@parrot.com>
	  <5265318C.5050307@st.com>
	 <1382373005.3284.61.camel@edumazet-glaptop.roam.corp.google.com>
	 <52656CE1.1060703@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>, netdev@vger.kernel.org
To: Jimmy PERCHET <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:63334 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384Ab3JUSYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 14:24:38 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so7381549pbc.18
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 11:24:38 -0700 (PDT)
In-Reply-To: <52656CE1.1060703@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-21 at 20:05 +0200, Jimmy PERCHET wrote:

> I understand your point. Nevertheless I think it is still possible
> to avoid serialization, and therefore increase performance, even if
> completions must remain in softirq. What do you think ?

I think this will break over time. This kind of 'optimizations' work on
a particular workload, and thats it. It reminds me the 'skb recycle'
thing.

The workload you try to optimize might conflict with other workloads.

Have you tried to reduce the 64 value in netif_napi_add() ?

> 
> In my patch I tried to avoid any race condition. (by updating both
> descriptor's cursors only once, for instance)
> Could you explain the possible race you see ?

Well, take a look at netif_queue_stopped(), netif_wake_queue(),
netif_queue_stopped() calls for a start.

Its really hard to make start_xmit() lockless (versus TX completion).

Adding atomic_t wont be enough (and btw thats often not needed at all)

drivers/net/ethernet/broadcom/tg3.c is a good reference if you really
want to do that properly.
