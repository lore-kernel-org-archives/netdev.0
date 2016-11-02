From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: Check for fullsock in sock_i_uid()
Date: Wed, 02 Nov 2016 01:39:03 -0700
Message-ID: <1478075943.7065.361.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478064420-11601-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34935 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753044AbcKBIjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 04:39:06 -0400
Received: by mail-pf0-f194.google.com with SMTP id i88so1150492pfk.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 01:39:05 -0700 (PDT)
In-Reply-To: <1478064420-11601-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-01 at 23:27 -0600, Subash Abhinov Kasiviswanathan wrote:
> sock_i_uid() acquires the sk_callback_lock which does not exist
> for sockets in TCP_NEW_SYN_RECV state. This results in errors
> showing up as spinlock bad magic.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/sock.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index c73e28f..af15ef0 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1727,7 +1727,10 @@ void sock_efree(struct sk_buff *skb)
>  
>  kuid_t sock_i_uid(struct sock *sk)
>  {
> -	kuid_t uid;
> +	kuid_t uid = GLOBAL_ROOT_UID;
> +
> +	if (!sk_fullsock(sk))
> +		return uid;
>  
>  	read_lock_bh(&sk->sk_callback_lock);
>  	uid = sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : GLOBAL_ROOT_UID;


This would be a bug in the caller.

Can you give us the complete stack trace leading to the problem you
had ?

Thanks !
