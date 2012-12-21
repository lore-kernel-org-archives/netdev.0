From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] net: sched: integer overflow fix
Date: Fri, 21 Dec 2012 14:51:48 -0800
Message-ID: <1356130308.21834.8014.camel@edumazet-glaptop>
References: <1356122364-1418-1-git-send-email-hasko.stevo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vimalkumar <j.vimal@gmail.com>
To: Stefan Hasko <hasko.stevo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356122364-1418-1-git-send-email-hasko.stevo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-12-21 at 21:39 +0100, Stefan Hasko wrote:
> Fixed integer overflow in function htb_dequeue
> 
> Signed-off-by: Stefan Hasko <hasko.stevo@gmail.com>
> ---
>  net/sched/sch_htb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index d2922c0..1bd3faa 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -919,7 +919,7 @@ ok:
>  	q->now = ktime_to_ns(ktime_get());
>  	start_at = jiffies;
>  
> -	next_event = q->now + 5 * NSEC_PER_SEC;
> +	next_event = q->now + (u32)5 * NSEC_PER_SEC;
>  
>  	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
>  		/* common case optimization - skip event handler quickly */

But this patch is wrong !

I am a bit surprised, as I remember spotting this error in one patch
submission from Vimalkumar.

Apparently it got lost.

Please fix the bug for good, not adding another one.

Thanks
