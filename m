From: Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Mon, 21 May 2007 10:51:38 -0400
Message-ID: <4651B1FA.3010201@gmail.com>
References: <20070518180903.GC3492@tuxdriver.com>	<1179622601.9453.4.camel@xo-28-0B-88.localdomain>	<464FA894.8090008@garzik.org> <20070520.003832.59470116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	marcelo-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linville-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070520.003832.59470116.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
> Date: Sat, 19 May 2007 21:47:00 -0400
>   
>> According to the implementation, netif_rx() can fail.
>>     
>
> It doesn't exactly "fail", but it does give return values
> which indicate RX congestion.
>   

Assuming you're referring to NET_RX_CN_*, this doesn't seem to be the 
case anymore: it appears netif_rx can only return NET_RX_SUCCESS or 
NET_RX_DROP.

The congestion level constants are hardly used at all - if they are 
left-overs, would it make sense ripping them out completely?

Either way I believe the following should be OK:


Remove inaccurate netif_rx() return value comments.

Signed-off-by: Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 dev.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f2b6111..79f5d90 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1628,9 +1628,6 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
  *
  *	return values:
  *	NET_RX_SUCCESS	(no congestion)
- *	NET_RX_CN_LOW   (low congestion)
- *	NET_RX_CN_MOD   (moderate congestion)
- *	NET_RX_CN_HIGH  (high congestion)
  *	NET_RX_DROP     (packet was dropped)
  *
  */
