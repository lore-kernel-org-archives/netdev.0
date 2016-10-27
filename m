From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: core: Add a UID field to struct sock.
Date: Thu, 27 Oct 2016 10:36:26 -0700
Message-ID: <1477589786.7065.220.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477588841-140767-1-git-send-email-lorenzo@google.com>
         <1477588841-140767-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ek@google.com,
        zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33286 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbcJ0Rg3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 13:36:29 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so3189531pfa.0
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 10:36:29 -0700 (PDT)
In-Reply-To: <1477588841-140767-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-28 at 02:20 +0900, Lorenzo Colitti wrote:

> diff --git a/net/core/sock.c b/net/core/sock.c
> index d8e4532e..831e4e8 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1570,6 +1570,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  		 */
>  		sk_refcnt_debug_inc(newsk);
>  		sk_set_socket(newsk, NULL);
> +		newsk->sk_uid = sk->sk_uid;

Not sure why this is needed ?

sk_clone_lock() already copies sk to newsk, using sock_copy(newsk, sk);

>  		newsk->sk_wq = NULL;
>  
>  		if (newsk->sk_prot->sockets_allocated)
> @@ -2460,8 +2461,11 @@ void sock_init_data(struct socket *sock, struct sock *sk)
