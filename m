From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Fix locking bug in lltx path
Date: Mon, 13 Sep 2004 15:39:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4145F789.7010502@pobox.com>
References: <m3vfei9gzv.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, arjanv@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m3vfei9gzv.fsf@averell.firstfloor.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Thanks to Arjan's spinlock debug kernel for finding it.
> 
> This fixes a silly missing spin lock in the relock path. For some 
> reason it seems to still work when you don't have spinlock debugging
> enabled.
> 
> Please apply.
> 
> -Andi
> 
> --------------------------------------------------------------------
> 
> Fix missing spin lock in lltx path.
> 
> Thanks to Arjan's spinlock debug kernel for finding it.
> 
> Signed-off-by: Andi Kleen <ak@muc.de>
> 
> diff -u linux-2.6.9rc1-bk19/net/sched/sch_generic.c-X linux-2.6.9rc1-bk19/net/sched/sch_generic.c
> --- linux-2.6.9rc1-bk19/net/sched/sch_generic.c-X	2004-09-13 08:51:46.000000000 +0200
> +++ linux-2.6.9rc1-bk19/net/sched/sch_generic.c	2004-09-13 19:22:50.000000000 +0200
> @@ -153,8 +153,10 @@
>  					spin_lock(&dev->queue_lock);
>  					return -1;
>  				}
> -				if (ret == -1 && nolock)
> +				if (ret == -1 && nolock) {
> +					spin_lock(&dev->queue_lock);
>  					goto collision; 
> +				}

please use the fancy new constants :)

	Jeff
