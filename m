From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] lib/dynamic_queue_limits.c: relax BUG_ON to WARN_ON in
 dql_complete()
Date: Wed, 18 Oct 2017 16:11:25 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD009B348@AcuExch.aculab.com>
References: <20171018154515.16751-1-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171018154515.16751-1-ard.biesheuvel@linaro.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ard Biesheuvel
> Sent: 18 October 2017 16:45
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

Don't you need to bound 'count' so that horrid things don't
happen further down the code?

	David
