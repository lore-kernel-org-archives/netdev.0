From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v2] notifier: Fix soft lockup for notifier_call_chain().
Date: Fri, 1 Jul 2016 11:06:11 +0800
Message-ID: <5775DE23.40101@huawei.com>
References: <57720369.6040507@huawei.com>
 <1467090824.6850.185.camel@edumazet-glaptop3.roam.corp.google.com>
 <5772149D.6040304@huawei.com>
 <1467094963.6850.189.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467095271.6850.192.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <luto@kernel.org>, <mingo@kernel.org>,
	<linux-kernel@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467095271.6850.192.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/6/28 14:27, Eric Dumazet wrote:
> On Tue, 2016-06-28 at 08:22 +0200, Eric Dumazet wrote:
> 
>> Follow the stack trace and add another cond_resched() where it is needed
>> then ?
>>
>> Lot of this code was written decade ago where nobody expected a root
>> user was going to try hard to crash its host ;)
>>
>> I did not check if the following is valid (Maybe __fib6_clean_all() is
>> called with some spinlock/rwlock held)
> 
> Well, fib6_run_gc() can call it with
> spin_lock_bh(&net->ipv6.fib6_gc_lock) so this wont work.
> 
> We need more invasive changes.
> 
> 
> 
Hi Eric:

I debug this problem, and found that the __fib6_clean_all() would not hold the cpu more than 1 second event though there
is a lot of ipv6 address to deal with, but the notifier_chian would call the ipv6 notifier several times and hold the cpu
for a long time, so add cond_resched() in the addrconf_ifdown could solve the problem correctly, I think your first solution
is the good way to fix this bug.

Thanks
Ding
