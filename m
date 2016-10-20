From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Replace semaphore stats_lock with mutex
Date: Thu, 20 Oct 2016 14:27:36 -0400 (EDT)
Message-ID: <20161020.142736.708413496078305369.davem@davemloft.net>
References: <1476953532-2019-1-git-send-email-binoy.jayan@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, arnd@arndb.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: binoy.jayan@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476953532-2019-1-git-send-email-binoy.jayan@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Binoy Jayan <binoy.jayan@linaro.org>
Date: Thu, 20 Oct 2016 14:22:12 +0530

> stats_lock is used as a simple mutex

No, it is not.

> @@ -1976,8 +1973,8 @@ int bnx2x_stats_safe_exec(struct bnx2x *bp,
>  	/* Wait for statistics to end [while blocking further requests],
>  	 * then run supplied function 'safely'.
>  	 */
> -	rc = down_timeout(&bp->stats_lock, HZ / 10);
> -	if (unlikely(rc)) {
> +	rc = mutex_trylock(&bp->stats_lock);
> +	if (unlikely(!rc)) {

It uses timeouts therefore this conversion is not 1 to 1.

You're losing functionality and potentially adding a regression.
