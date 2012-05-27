From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0xb1b/0xc70()
Date: Sun, 27 May 2012 21:46:11 +0200
Message-ID: <1338147971.3786.55.camel@edumazet-glaptop>
References: <4FBFEACC.8040601@fastmail.fm>
	 <1337978725.10135.0.camel@edumazet-glaptop>
	 <1337979331.10135.2.camel@edumazet-glaptop> <4FC0BCE1.6070601@fastmail.fm>
	 <1338127184.3670.50.camel@edumazet-glaptop> <4FC24987.4090708@fastmail.fm>
	 <1338140156.3786.10.camel@edumazet-glaptop>  <4FC27CE7.20604@fastmail.fm>
	 <1338147374.3786.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Jack Stone <jwjstone@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:59408 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab2E0TqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2012 15:46:14 -0400
In-Reply-To: <1338147374.3786.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-05-27 at 21:36 +0200, Eric Dumazet wrote:
> pied elsewhere, so we can double check.
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3ba605f..22e4c9a 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1606,8 +1606,10 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  			if (tcp_hdr(skb)->fin)
>  				goto found_fin_ok;
>  			WARN(!(flags & MSG_PEEK),
> -			     "recvmsg bug 2: copied %X seq %X rcvnxt %X fl %X\n",
> -			     *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt, flags);
> +			     "recvmsg bug 2: copied %X seq %X end_seq %X rcvnxt %X fl %X offset %u len %u syn %d tcp_flags %X\n",
> +			     *seq, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
> +			     tp->rcv_nxt, flags, offset, skb->len, tcp_hdr(skb)->syn,
> +				 TCP_SKB_CB(skb)->tcp_flags);
>  		}
>  
>  		/* Well, if we have backlog, try to process it now yet. */
> 

Oh well, ignore this, as tcp_flags is only set in output path.
