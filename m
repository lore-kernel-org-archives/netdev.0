From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: refine pacing rate determination
Date: Tue, 25 Aug 2015 11:34:04 -0700 (PDT)
Message-ID: <20150825.113404.916165871303626879.davem@davemloft.net>
References: <1440203882.29244.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754825AbbHYSeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:34:05 -0400
In-Reply-To: <1440203882.29244.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Aug 2015 17:38:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When TCP pacing was added back in linux-3.12, we chose
> to apply a fixed ratio of 200 % against current rate,
> to allow probing for optimal throughput even during
> slow start phase, where cwnd can be doubled every other gRTT.
> 
> At Google, we found it was better applying a different ratio
> while in Congestion Avoidance phase.
> This ratio was set to 120 %.
> 
> We've used the normal tcp_in_slow_start() helper for a while,
> then tuned the condition to select the conservative ratio
> as soon as cwnd >= ssthresh/2 :
> 
> - After cwnd reduction, it is safer to ramp up more slowly,
>   as we approach optimal cwnd.
> - Initial ramp up (ssthresh == INFINITY) still allows doubling
>   cwnd every other RTT.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
