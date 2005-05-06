From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] TSO Reloaded
Date: Fri, 6 May 2005 17:10:05 +1000
Message-ID: <20050506071005.GG8255@krispykreme>
References: <20050504230731.12be1bc3.davem@davemloft.net> <20050506043653.GD8255@krispykreme> <20050506054516.GE8255@krispykreme> <20050505231345.4296d9b5.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050505231345.4296d9b5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> I know what is causing the breaks, it's the "cache line align" crap
> in tcp_sendmsg().
> 
> Comment out this alignment code in net/ipv4/tcp.c and see how it goes:
> 
> 					/* If page is cached, align
> 					 * offset to L1 cache boundary
> 					 */
> 					off = (off + L1_CACHE_BYTES - 1) &
> 					      ~(L1_CACHE_BYTES - 1);
> 
> This alignment causes TSO coalescing to fail at these spots.
> 
> You should not see this effect when sendfile() is used for
> the transfer.

Nice work! Its looking much better now.

Anton

1500 MTU:
eth0 data: 74 frags:
eth0 data: 66 frags: 2892 4
eth0 data: 66 frags: 1200 1692 4
eth0 data: 66 frags: 2400 492 4
eth0 data: 66 frags: 2892 4
eth0 data: 66 frags: 704 744
eth0 data: 66 frags: 3352 4096 1236 4
eth0 data: 66 frags: 2856 36 4

1500 MTU+sendfile:
eth0 data: 74 frags:
eth0 data: 66 frags: 2892 4
eth0 data: 66 frags: 1200 1692 4
eth0 data: 66 frags: 2400 492 4
eth0 data: 66 frags: 2892 4
eth0 data: 66 frags: 704 744
eth0 data: 66 frags: 3348 4
eth0 data: 66 frags: 4092 4

9000 MTU:
eth0 data: 74 frags:
eth0 data: 66 frags: 4096 4096 4096 4096 1508 4
eth0 data: 66 frags: 2584 4096 2268
eth0 data: 66 frags: 1828 4096 3024
eth0 data: 66 frags: 1072 4096 4096 4096 4096 4096 4096 1192 4
eth0 data: 66 frags: 2900 4096 4096 4096 2704 4
eth0 data: 66 frags: 1388 4096 3464
eth0 data: 66 frags: 632 4096 4096 4096 4096 876 4

9000 MTU+sendfile:
eth0 data: 74 frags:
eth0 data: 66 frags: 4096 4096 4092 4
eth0 data: 66 frags: 4096 4096 4096 4096 1508 4
eth0 data: 66 frags: 2584 4096 4092 4
eth0 data: 66 frags: 4096 4096 4096 4096 1508 4
eth0 data: 66 frags: 2584 4096 4096 4096 3020 4
eth0 data: 66 frags: 1072 4096 4096 4096 4096 436 4
eth0 data: 66 frags: 3656 4096 4096 4096 1948 4
