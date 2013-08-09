From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp:elapsed variable calculated twice while
 keepalive working
Date: Fri, 09 Aug 2013 11:12:29 -0700 (PDT)
Message-ID: <20130809.111229.1955078847385749897.davem@davemloft.net>
References: <1375792738-19099-1-git-send-email-tingw.liu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	eric.dumazet@gmail.com
To: tingw.liu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758588Ab3HISMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:12:30 -0400
In-Reply-To: <1375792738-19099-1-git-send-email-tingw.liu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tingwei Liu <tingw.liu@gmail.com>
Date: Tue,  6 Aug 2013 20:38:58 +0800

> When tcp keepalive working elapsed calculated twice while the first time is not needed!
> 
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>


Please put a space after "tcp:" in your Subject line prefixes, it looks
awful the way you've done it here.

> @@ -591,11 +591,11 @@ static void tcp_keepalive_timer (unsigned long data)
>  	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state == TCP_CLOSE)
>  		goto out;
>  
> -	elapsed = keepalive_time_when(tp);
> -
>  	/* It is alive without keepalive 8) */
> -	if (tp->packets_out || tcp_send_head(sk))
> +	if (tp->packets_out || tcp_send_head(sk)) {
> +		elapsed = keepalive_time_when(tp);
>  		goto resched;
> +	}
>  
>  	elapsed = keepalive_time_elapsed(tp);

This is overkill, just delete the second assignment.  Your version makes
the code look less elegant and also makes it harder to audit.
