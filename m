From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] pkt_sched: fq: fix non TCP flows pacing
Date: Tue, 08 Oct 2013 21:54:38 -0400 (EDT)
Message-ID: <20131008.215438.1267371108723725778.davem@davemloft.net>
References: <1381182269.12191.27.camel@edumazet-glaptop.roam.corp.google.com>
	<1381270560.12191.64.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sesse@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494Ab3JIByk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 21:54:40 -0400
In-Reply-To: <1381270560.12191.64.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Oct 2013 15:16:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Steinar reported FQ pacing was not working for UDP flows.
> 
> It looks like the initial sk->sk_pacing_rate value of 0 was
> a wrong choice. We should init it to ~0U (unlimited)
> 
> Then, TCA_FQ_FLOW_DEFAULT_RATE should be removed because it makes
> no real sense. The default rate is really unlimited, and we
> need to avoid a zero divide.
> 
> Reported-by: Steinar H. Gunderson <sesse@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> I removed the ACCESS_ONCE() stuff, as it adds conflicts for
> next (net / net-next) merge. I'll send a separate patch later.

Applied, thanks Eric.
