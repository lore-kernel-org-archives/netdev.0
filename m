From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pktgen: don't abuse current->state in
 pktgen_thread_worker()
Date: Thu, 06 Aug 2015 23:52:59 -0700 (PDT)
Message-ID: <20150806.235259.2089819677267479973.davem@davemloft.net>
References: <20150804163334.GA31842@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.huang@intel.com, ast@plumgrid.com, jstancek@redhat.com,
	brouer@redhat.com, mleitner@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: oleg@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150804163334.GA31842@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oleg Nesterov <oleg@redhat.com>
Date: Tue, 4 Aug 2015 18:33:34 +0200

> Commit 1fbe4b46caca "net: pktgen: kill the Wait for kthread_stop
> code in pktgen_thread_worker()" removed (in particular) the final
> __set_current_state(TASK_RUNNING) and I didn't notice the previous
> set_current_state(TASK_INTERRUPTIBLE). This triggers the warning
> in __might_sleep() after return.
> 
> Afaics, we can simply remove both set_current_state()'s, and we
> could do this a long ago right after ef87979c273a2 "pktgen: better
> scheduler friendliness" which changed pktgen_thread_worker() to
> use wait_event_interruptible_timeout().
> 
> Reported-by: Huang Ying <ying.huang@intel.com>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Applied, thank you.
