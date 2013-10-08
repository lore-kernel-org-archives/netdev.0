From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: fix non TCP flows pacing
Date: Tue, 08 Oct 2013 16:53:18 -0400 (EDT)
Message-ID: <20131008.165318.1392122841162708841.davem@davemloft.net>
References: <1381182269.12191.27.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sesse@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab3JHUxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:53:20 -0400
In-Reply-To: <1381182269.12191.27.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Oct 2013 14:44:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Steinar reported FQ pacing was not working for UDP flows.
> 
> It looks like the initial sk->sk_pacing_rate value of 0 was
> a wrong choice. We should init it to ~0U like sk_max_pacing_rate
> 
> Then, TCA_FQ_FLOW_DEFAULT_RATE should be removed because it makes
> no real sense. (The default rate is really : ~0U)
> 
> While debugging this issue, I realized sk_pacing_rate is shared between
> transport and packet scheduler without locking / barriers :
> 
> We should use ACCESS_ONCE() to make sure compiler wont perform
> multiple loads or stores.
> 
> Reported-by: Steinar H. Gunderson <sesse@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Is this meant for net or net-next?  It doesn't apply cleanly to the
former.
