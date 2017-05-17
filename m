From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: always include tcp.h in sock.c
Date: Wed, 17 May 2017 07:59:55 -0700
Message-ID: <1495033195.6465.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170517084800.1272163-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517084800.1272163-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-05-17 at 10:47 +0200, Arnd Bergmann wrote:
> kernelci reports a build regression in the latest 4.12 snapshots
> in configurations without TCP:
> 
> net/core/sock.c: In function 'skb_orphan_partial':
> net/core/sock.c:1810:6: error: implicit declaration of function 'skb_is_tcp_pure_ack' [-Werror=implicit-function-declaration]
> 
> The declaration is simply missing because the header is included
> conditionally. There is no real reason to leave out the header, so
> this just removes the #ifdef.
> 
> Fixes: f6ba8d33cfbb ("netem: fix skb_orphan_partial()")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  net/core/sock.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index e43e71d7856b..727f924b7f91 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -139,10 +139,7 @@
>  
>  #include <trace/events/sock.h>
>  
> -#ifdef CONFIG_INET
>  #include <net/tcp.h>
> -#endif
> -
>  #include <net/busy_poll.h>
>  
>  static DEFINE_MUTEX(proto_list_mutex);


I sent the same patch yesterday.  

https://patchwork.ozlabs.org/patch/763165/

Thanks.
