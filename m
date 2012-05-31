From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/3] bql: Fix POSDIFF() to integer overflow aware.
Date: Thu, 31 May 2012 09:58:38 +0200
Message-ID: <1338451118.2760.1273.camel@edumazet-glaptop>
References: <20120531072439.6c634a0b.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, therbert@google.com, denys@visp.net.lb,
	netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44702 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757764Ab2EaH6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 03:58:43 -0400
Received: by bkcji2 with SMTP id ji2so546907bkc.19
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 00:58:42 -0700 (PDT)
In-Reply-To: <20120531072439.6c634a0b.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-31 at 07:24 +0900, Hiroaki SHIMODA wrote:
> POSDIFF() fails to take into account integer overflow case.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Denys Fedoryshchenko <denys@visp.net.lb>
> ---
>  lib/dynamic_queue_limits.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
> index 6ab4587..c87eb76 100644
> --- a/lib/dynamic_queue_limits.c
> +++ b/lib/dynamic_queue_limits.c
> @@ -10,7 +10,7 @@
>  #include <linux/jiffies.h>
>  #include <linux/dynamic_queue_limits.h>
>  
> -#define POSDIFF(A, B) ((A) > (B) ? (A) - (B) : 0)
> +#define POSDIFF(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
>  
>  /* Records completed count and recalculates the queue limit */
>  void dql_completed(struct dql *dql, unsigned int count)

Acked-by: Eric Dumazet <edumazet@google.com>
