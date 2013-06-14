From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-rps: fixes for rps flow limit
Date: Thu, 13 Jun 2013 17:13:39 -0700 (PDT)
Message-ID: <20130613.171339.2275946127393500284.davem@davemloft.net>
References: <1371151778-14697-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818Ab3FNANk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 20:13:40 -0400
In-Reply-To: <1371151778-14697-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 13 Jun 2013 15:29:38 -0400

> Caught by sparse:
> - __rcu: missing annotation to sd->flow_limit
> - __user: direct access in cpumask_scnprintf
> 
> Also
> - add endline character when printing bitmap if room in buffer
> - avoid bucket overflow by reducing FLOW_LIMIT_HISTORY
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> (first item)
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, and:

> The last item warrants some explanation. The hashtable buckets are
> subject to overflow if FLOW_LIMIT_HISTORY is larger than or equal
> to bucket size, since all packets may end up in a single bucket. The
> current (rather arbitrary) history value of 256 happens to match the
> buffer size (u8).
> 
> As a result, with a single flow, the first 128 packets are accepted
> (correct), the second 128 packets dropped (correct) and then the
> history[] array has filled, so that each subsequent new packet
> causes an increment in the bucket for new_flow plus a decrement
> for old_flow: a steady state.
> 
> This is fine if packets are dropped, as the steady state goes away
> as soon as a mix of traffic reappears. But, because the 256th packet
> overflowed the bucket to 0: no packets are dropped.
> 
> Instead of explicitly adding an overflow check, this patch changes
> FLOW_LIMIT_HISTORY to never be able to overflow a single bucket.

I put this text into the commit message, the more information in the
commit log the better.
