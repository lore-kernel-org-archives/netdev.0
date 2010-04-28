From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Wed, 28 Apr 2010 14:36:10 -0700 (PDT)
Message-ID: <20100428.143610.232922250.davem@davemloft.net>
References: <1272458001.2267.0.camel@edumazet-laptop>
	<1272458174.14068.16.camel@bigi>
	<1272463605.2267.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, xiaosuo@gmail.com, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, eilong@broadcom.com,
	bmb@athenacr.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59647
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754988Ab0D1VgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 17:36:06 -0400
In-Reply-To: <1272463605.2267.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Apr 2010 16:06:45 +0200

> [PATCH net-next-2.6] net: speedup udp receive path
> 
> Since commit 95766fff ([UDP]: Add memory accounting.), 
> each received packet needs one extra sock_lock()/sock_release() pair.
> 
> This added latency because of possible backlog handling. Then later,
> ticket spinlocks added yet another latency source in case of DDOS.
> 
> This patch introduces lock_sock_bh() and unlock_sock_bh()
> synchronization primitives, avoiding one atomic operation and backlog
> processing.
> 
> skb_free_datagram_locked() uses them instead of full blown
> lock_sock()/release_sock(). skb is orphaned inside locked section for
> proper socket memory reclaim, and finally freed outside of it.
> 
> UDP receive path now take the socket spinlock only once.
> 
> Signed-off-by: Eric DUmazet <eric.dumazet@gmail.com>

Clever, let's see what this breaks :-)

Applied, thanks Eric.
