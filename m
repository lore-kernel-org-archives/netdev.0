From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet_diag: Remove _bh suffix in
 inet_diag_dump_reqs().
Date: Thu, 18 Jun 2015 23:42:08 -0700
Message-ID: <1434696128.31511.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434627654-3630-1-git-send-email-shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Hiroaki Shimoda <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34536 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbbFSGmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 02:42:13 -0400
Received: by wgfq1 with SMTP id q1so34686374wgf.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 23:42:11 -0700 (PDT)
In-Reply-To: <1434627654-3630-1-git-send-email-shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-18 at 20:40 +0900, Hiroaki Shimoda wrote:
> inet_diag_dump_reqs() is called from inet_diag_dump_icsk() with BH
> disabled. So no need to disable BH in inet_diag_dump_reqs().
> 
> Signed-off-by: Hiroaki Shimoda <shimoda.hiroaki@gmail.com>
> ---
>  net/ipv4/inet_diag.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 21985d8d41e7..4ca789ba63cb 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -746,7 +746,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
>  
>  	entry.family = sk->sk_family;
>  
> -	spin_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
> +	spin_lock(&icsk->icsk_accept_queue.syn_wait_lock);
>  
>  	lopt = icsk->icsk_accept_queue.listen_opt;
>  	if (!lopt || !listen_sock_qlen(lopt))
> @@ -794,7 +794,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
>  	}
>  
>  out:
> -	spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
> +	spin_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
>  
>  	return err;
>  }

Sure, although this will soon be removed completely when SYN_RECV
sockets will be stored in regular ehash table.

Thanks
