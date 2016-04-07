From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sock: make lockdep_sock_is_held static inline
Date: Thu, 07 Apr 2016 15:30:27 -0700
Message-ID: <1460068227.6473.422.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36645 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbcDGWaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:30:30 -0400
Received: by mail-pa0-f54.google.com with SMTP id bx7so46375128pad.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:30:30 -0700 (PDT)
In-Reply-To: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-07 at 23:53 +0200, Hannes Frederic Sowa wrote:
> I forgot to add inline to lockdep_sock_is_held, so it generated all
> kinds of build warnings if not build with lockdep support.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/sock.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index eb2d7c3e120b25..46b29374df8ed7 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1360,7 +1360,7 @@ do {									\
>  	lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
>  } while (0)
>  
> -static bool lockdep_sock_is_held(const struct sock *csk)
> +static inline bool lockdep_sock_is_held(const struct sock *csk)
>  {
>  	struct sock *sk = (struct sock *)csk;
>  


But... this wont solve the compiler error ?

include/net/sock.h: In function 'lockdep_sock_is_held':
include/net/sock.h:1367:2: error: implicit declaration of function
'lockdep_is_held' [-Werror=implicit-function-declaration]
In file included from security/lsm_audit.c:20:0:
include/net/sock.h: In function 'lockdep_sock_is_held':
include/net/sock.h:1367:2: error: implicit declaration of function
'lockdep_is_held' [-Werror=implicit-function-declaration]

$ egrep "LOCKDEP|PROVE" .config
CONFIG_LOCKDEP_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
# CONFIG_PROVE_RCU is not set
