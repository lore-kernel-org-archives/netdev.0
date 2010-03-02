From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH V2] net: add accounting for socket backlog
Date: Tue, 02 Mar 2010 10:34:02 +0800
Message-ID: <1267497242.23196.62.camel@debian>
References: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
	 <1267335071.9082.56.camel@edumazet-laptop>
	 <1267443828.3039.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43652 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193Ab0CBCcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 21:32:20 -0500
In-Reply-To: <1267443828.3039.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-01 at 19:43 +0800, Eric Dumazet wrote:
> Thinking again about this, doing this zero initialization at the very
> end of __release_sock() solves the problem of potential infinite loop
> in
> __release_sock(). Since producer will hit the backlog limit.
> 
> Thanks
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 305cba4..544cf4a 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1542,6 +1542,11 @@ static void __release_sock(struct sock *sk)
>  
>                 bh_lock_sock(sk);
>         } while ((skb = sk->sk_backlog.head) != NULL);
> +       /*
> +        * Doing this zeroing at the end of this function guarantee we
> can not
> +        * loop forever while a wild producer attempts to flood us
> +        */
> +       sk->sk_backlog.len = 0;
>  } 

Very good point. I'll add your sob in my next patch.

Thanks,
-yi

