From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: temporarily disable Fast Open on SYN
 timeout
Date: Tue, 29 Oct 2013 22:51:22 -0400 (EDT)
Message-ID: <20131029.225122.1012560091000427156.davem@davemloft.net>
References: <1383066545-27348-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab3J3CvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:51:24 -0400
In-Reply-To: <1383066545-27348-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue, 29 Oct 2013 10:09:05 -0700

> Fast Open currently has a fall back feature to address SYN-data
> being dropped by but it requires the middle-box to pass on regular
> SYN retry after SYN-data. This is implemented in commit aab487435
> ("net-tcp: Fast Open client - detecting SYN-data drops")
> 
> However some NAT boxes will drop all subsequent packets after first
> SYN-data and blackholes the entire connections.  An example is incommit
> 356d7d8 "netfilter: nf_conntrack: fix tcp_in_window for Fast Open".
> 
> The sender should note such incidents and falls back to use regular
> TCP handshake on subsequent attempt temporarily as well: after the
> second SYN timeouts the original Fast Open SYN is most likely lost.
> When such an event recurs Fast Open is disabled based on the number
> of recurrences exponentially.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
