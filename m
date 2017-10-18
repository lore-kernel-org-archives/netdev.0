From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] lib/dynamic_queue_limits.c: relax BUG_ON to WARN_ON in
 dql_complete()
Date: Wed, 18 Oct 2017 09:29:48 -0700
Message-ID: <1508344188.31614.124.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171018154515.16751-1-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        davem@davemloft.net
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171018154515.16751-1-ard.biesheuvel@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-18 at 16:45 +0100, Ard Biesheuvel wrote:
> Even though calling dql_completed() with a count that exceeds the
> queued count is a serious error, it still does not justify bringing
> down the entire kernel with a BUG_ON(). So relax it to a WARN_ON()
> instead.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  lib/dynamic_queue_limits.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
> index f346715e2255..24ce495d78f3 100644
> --- a/lib/dynamic_queue_limits.c
> +++ b/lib/dynamic_queue_limits.c
> @@ -23,7 +23,7 @@ void dql_completed(struct dql *dql, unsigned int count)
>  	num_queued = ACCESS_ONCE(dql->num_queued);
>  
>  	/* Can't complete more than what's in queue */
> -	BUG_ON(count > num_queued - dql->num_completed);
> +	WARN_ON(count > num_queued - dql->num_completed);
>  
>  	completed = dql->num_completed + count;
>  	limit = dql->limit;

So instead fixing the faulty driver, you'll have strange lockups, and
force your users to reboot anyway, after annoying periods where
"Internet does not work"

These kinds of errors should be found when testing a new device driver
or new kernel.

Have you found the root cause ?
