From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH RFC 02/26] task_work: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Fri, 30 Jun 2017 13:04:45 +0200
Message-ID: <20170630110445.GA5123@redhat.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-2-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, akpm@linux-foundation.org,
        mingo@redhat.com, dave@stgolabs.net, manfred@colorfullife.com,
        tj@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org,
        will.deacon@arm.com, peterz@infradead.org,
        stern@rowland.harvard.edu, parri.andrea@gmail.com,
        torvalds@linux-foundation.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498780894-8253-2-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/29, Paul E. McKenney wrote:
>
> --- a/kernel/task_work.c
> +++ b/kernel/task_work.c
> @@ -109,7 +109,8 @@ void task_work_run(void)
>  		 * the first entry == work, cmpxchg(task_works) should
>  		 * fail, but it can play with *work and other entries.
>  		 */
> -		raw_spin_unlock_wait(&task->pi_lock);
> +		raw_spin_lock(&task->pi_lock);
> +		raw_spin_unlock(&task->pi_lock);

Well, bit the you need spin_lock_irq(). And this is one of the reasons
why I personally think unlock_wait have some sense...

Oleg.
