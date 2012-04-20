From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: [PATCH 1/2] workqueue: Catch more locking problems with
 flush_work()
Date: Fri, 20 Apr 2012 13:26:33 +0800
Message-ID: <20120420052633.GA16219@zhy>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org>
 <20120419081002.GB3963@zhy>
 <4F905B30.4080501@codeaurora.org>
Reply-To: Yong Zhang <yong.zhang0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F905B30.4080501@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 19, 2012 at 11:36:32AM -0700, Stephen Boyd wrote:
> Does looking at the second patch help? Basically schedule_work() can run
> the callback right between the time the mutex is acquired and
> flush_work() is called:
> 
> CPU0                        CPU1
> 
> <irq>
>   schedule_work()           mutex_lock(&mutex)
> <irq return>
>     my_work()               flush_work() 
>       mutex_lock(&mutex)    
>       <deadlock>

Get you point. It is a problem. But your patch could introduece false
positive since when flush_work() is called that very work may finish
running already.

So I think we need the lock_map_acquire()/lock_map_release() only when
the work is under processing, no?

Thanks,
Yong
