From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] workqueue: Catch more locking problems with
 flush_work()
Date: Thu, 19 Apr 2012 08:28:41 -0700
Message-ID: <20120419152841.GA10553@google.com>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Dooks <ben-linux@fluff.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 18, 2012 at 08:25:57PM -0700, Stephen Boyd wrote:
> @@ -2513,8 +2513,11 @@ bool flush_work(struct work_struct *work)
>  		wait_for_completion(&barr.done);
>  		destroy_work_on_stack(&barr.work);
>  		return true;
> -	} else
> +	} else {
> +		lock_map_acquire(&work->lockdep_map);
> +		lock_map_release(&work->lockdep_map);
>  		return false;

We don't have this annotation when start_flush_work() succeeds either,
right?  IOW, would lockdep trigger when an actual deadlock happens?
If not, why not add the acquire/release() before flush_work() does
anything?

Thanks.

-- 
tejun
