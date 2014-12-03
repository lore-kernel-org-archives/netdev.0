From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: remove useless spin_lock/spin_unlock
Date: Tue, 02 Dec 2014 17:57:59 -0800
Message-ID: <1417571879.5303.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <547E6832.4070403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:41913 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbaLCB6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 20:58:00 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so14374809pdi.17
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 17:58:00 -0800 (PST)
In-Reply-To: <547E6832.4070403@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-03 at 09:32 +0800, Duan Jiong wrote:
> xchg is atomic, so there is no necessary to use spin_lock/spin_unlock
> to protect it.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/ipv6/ipv6_sockglue.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index e1a9583..92ca907 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -112,9 +112,7 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
>  		}
>  		opt = xchg(&inet6_sk(sk)->opt, opt);
>  	} else {
> -		spin_lock(&sk->sk_dst_lock);
>  		opt = xchg(&inet6_sk(sk)->opt, opt);
> -		spin_unlock(&sk->sk_dst_lock);
>  	}
>  	sk_dst_reset(sk);
>  

Why keeping 2 copies of opt = xchg(&inet6_sk(sk)->opt, opt); then ?
