From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: send loss probe after 1s if no RTT
 available
Date: Mon, 21 Sep 2015 16:19:19 -0700 (PDT)
Message-ID: <20150921.161919.1105069799353968079.davem@davemloft.net>
References: <1442601633-28619-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, ncardwell@google.com,
	edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbbIUXTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:19:20 -0400
In-Reply-To: <1442601633-28619-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 18 Sep 2015 11:40:33 -0700

> This patch makes TLP to use 1 sec timer by default when RTT is
> not available due to SYN/ACK retransmission or SYN cookies.
> 
> Prior to this change, the lack of RTT prevents TLP so the first
> data packets sent can only be recovered by fast recovery or RTO.
> If the fast recovery fails to trigger the RTO is 3 second when
> SYN/ACK is retransmitted. With this patch we can trigger fast
> recovery in 1sec instead.
> 
> Note that we need to check Fast Open more properly. A Fast Open
> connection could be (accepted then) closed before it receives
> the final ACK of 3WHS so the state is FIN_WAIT_1. Without the
> new check, TLP will retransmit FIN instead of SYN/ACK.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
