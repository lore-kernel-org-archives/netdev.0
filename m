From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] notifier: Fix soft lockup for notifier_call_chain().
Date: Tue, 28 Jun 2016 08:27:51 +0200
Message-ID: <1467095271.6850.192.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57720369.6040507@huawei.com>
	 <1467090824.6850.185.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5772149D.6040304@huawei.com>
	 <1467094963.6850.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luto@kernel.org, mingo@kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467094963.6850.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-28 at 08:22 +0200, Eric Dumazet wrote:

> Follow the stack trace and add another cond_resched() where it is needed
> then ?
> 
> Lot of this code was written decade ago where nobody expected a root
> user was going to try hard to crash its host ;)
> 
> I did not check if the following is valid (Maybe __fib6_clean_all() is
> called with some spinlock/rwlock held)

Well, fib6_run_gc() can call it with
spin_lock_bh(&net->ipv6.fib6_gc_lock) so this wont work.

We need more invasive changes.
