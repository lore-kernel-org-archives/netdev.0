From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 23 Sep 2004 00:06:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922220628.GC2619@wotan.suse.de>
References: <20040920063012.GL2825@krispykreme> <20040920203021.GD4242@wotan.suse.de> <20040921155835.18aee381.davem@davemloft.net> <20040922140000.GD27432@wotan.suse.de> <20040922111209.7887df53.davem@davemloft.net> <20040922195515.GA2619@wotan.suse.de> <c0a09e5c04092213126ba5f29d@mail.gmail.com> <20040922133906.7d57ef49.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Grover <andy.grover@gmail.com>, ak@suse.de, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040922133906.7d57ef49.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> One thing that could be biting us is the nagle check which
> probably needs to be adjusted to use the standard MSS not
> the TSO one... perhaps play with this patch:

I tried it and it breaks the performance completely
(21MB/s) 

-Andi

> 
> ===== include/net/tcp.h 1.88 vs edited =====
> --- 1.88/include/net/tcp.h	2004-09-14 13:57:07 -07:00
> +++ edited/include/net/tcp.h	2004-09-22 13:18:43 -07:00
> @@ -1505,7 +1505,7 @@
>  	 * final FIN frame.  -DaveM
>  	 */
>  	return (((nonagle&TCP_NAGLE_PUSH) || tp->urg_mode
> -		 || !tcp_nagle_check(tp, skb, cur_mss, nonagle)) &&
> +		 || !tcp_nagle_check(tp, skb, tp->mss_cache_std, nonagle)) &&
>  		(((tcp_packets_in_flight(tp) + (pkts-1)) < tp->snd_cwnd) ||
>  		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
>  		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd));
> 
> 
