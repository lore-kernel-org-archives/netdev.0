From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xfrm: replace xfrm_policy_afinfo_lock spinlock with
 mutex
Date: Thu, 04 Jul 2013 02:50:04 -0700
Message-ID: <1372931404.4979.88.camel@edumazet-glaptop>
References: <1372920827-4144-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.hengli.com.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:43221 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585Ab3GDJuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 05:50:07 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld11so1145215pab.36
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 02:50:06 -0700 (PDT)
In-Reply-To: <1372920827-4144-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-04 at 14:53 +0800, Fan Du wrote:
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/xfrm/xfrm_policy.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index e52cab3..27768ba 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -46,7 +46,7 @@ static DEFINE_SPINLOCK(xfrm_policy_sk_bundle_lock);
>  static struct dst_entry *xfrm_policy_sk_bundles;
>  static DEFINE_RWLOCK(xfrm_policy_lock);
>  
> -static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
> +static DEFINE_MUTEX(xfrm_policy_afinfo_lock);

Why is it needed, and why is it safe ?

Is it a bug fix ? If answer is no please read : 

http://www.spinics.net/lists/netdev/msg242161.html

This mutex or spinlock is not really needed anyway.

Check commit e0386005ff2a729 for a starting point.
("net: inet_add_protocol() can use cmpxchg()")

But do not send a patch until David reopens net-next.
