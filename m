From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: Fix a connect() race with timewait sockets
Date: Tue, 08 Dec 2009 20:19:00 -0800 (PST)
Message-ID: <20091208.201900.109640288.davem@davemloft.net>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
	<4B152F97.1090409@gmail.com>
	<4B1912FE.9020600@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, zbr@ioremap.net
To: eric.dumazet@gmail.com
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4B1912FE.9020600@gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 Dec 2009 14:47:42 +0100

> When we find a timewait connection in __inet_hash_connect() and reuse
> it for a new connection request, we have a race window, releasing bind
> list lock and reacquiring it in __inet_twsk_kill() to remove timewait
> socket from list.
> 
> Another thread might find the timewait socket we already chose, leading to
> list corruption and crashes.
> 
> Fix is to remove timewait socket from bind list before releasing the bind lock.
> 
> Note: This problem happens if sysctl_tcp_tw_reuse is set.
> 
> Reported-by: kapil dakhane <kdakhane@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!
