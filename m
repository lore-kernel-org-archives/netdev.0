From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use TCP_INIT_CWND in tcp_fixup_sndbuf()
Date: Wed, 19 Oct 2011 16:55:55 -0400 (EDT)
Message-ID: <20111019.165555.386071219519696637.davem@davemloft.net>
References: <1318566282.2533.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab1JSUz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 16:55:58 -0400
In-Reply-To: <1318566282.2533.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 14 Oct 2011 06:24:42 +0200

> Initial cwnd being 10 (TCP_INIT_CWND) instead of 3, change
> tcp_fixup_sndbuf() to get more than 16384 bytes (sysctl_tcp_wmem[1]) in
> initial sk_sndbuf
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.  Another reason to obliterate all magic constants :-)

> I believe a similar change in tcp_fixup_rcvbuf() is needed too.

And tcp_init_buffer_space() has a similar set of "4 * tp->advmss"
calculations.

And then some "2 * tp->advmss" cases, also having to do with window
clamping.
