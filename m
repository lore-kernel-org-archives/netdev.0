From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: avoid unnecessary dirtying of
 critical fields
Date: Sun, 20 Nov 2016 09:26:54 -0800
Message-ID: <1479662814.8455.366.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479500133.8455.295.camel@edumazet-glaptop3.roam.corp.google.com>
         <62f9c9ee-d710-7493-1094-e8ffe8aaa1ca@gmail.com>
         <1479662102.8455.361.camel@edumazet-glaptop3.roam.corp.google.com>
         <1479662676.8455.364.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35908 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbcKTR04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 12:26:56 -0500
Received: by mail-pf0-f194.google.com with SMTP id c4so14164845pfb.3
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 09:26:56 -0800 (PST)
In-Reply-To: <1479662676.8455.364.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-11-20 at 09:24 -0800, Eric Dumazet wrote:

>  		/* Current cpu is not according to smp_irq_affinity -
> -		 * probably affinity changed. need to stop this NAPI
> -		 * poll, and restart it on the right CPU
> +		 * probably affinity changed. Need to stop this NAPI
> +		 * poll, and restart it on the right CPU.
> +		 * Try to avoid returning a too small value (like 0),
> +		 * to not fool net_rx_action() and its netdev_budget
>  		 */
> -		done = 0;
> +		if (done)
> +			done--;


Note : This could have been a net candidate, but bug is minor and I
prefer to avoid a merge conflict, since net-next has the additional if
around the napi_complete_done() call.


>  	}
>  	/* Done for now */
>  	if (napi_complete_done(napi, done))
> 
