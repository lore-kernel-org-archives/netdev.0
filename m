From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Sat, 13 Mar 2010 13:33:56 +0800
Message-ID: <20100313053356.GC3704@hack>
References: <20100311134556.GA6344@linux.vnet.ibm.com> <20100311161751.GA3804@hack> <2375c9f91003112356g1b4164e4pb5f63f0e0e2f310a@mail.gmail.com> <20100312.000705.225033546.davem@davemloft.net> <2375c9f91003120059g771d162fxefc21beb2ab17b4d@mail.gmail.com> <1268392276.3141.4.camel@edumazet-laptop> <2375c9f91003120511j6f33592cl12cb2617a27351ec@mail.gmail.com> <1268401058.3141.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	peterz@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1268401058.3141.9.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 12, 2010 at 02:37:38PM +0100, Eric Dumazet wrote:
>Le vendredi 12 mars 2010 =C3=A0 21:11 +0800, Am=C3=A9rico Wang a =C3=A9=
crit :
>
>> Oh, but lockdep complains about rcu_read_lock(), it said
>> rcu_read_lock() can't be used in softirq context.
>>=20
>> Am I missing something?
>
>Well, lockdep might be dumb, I dont know...
>
>I suggest you read rcu_read_lock_bh kernel doc :
>
>/**
> * rcu_read_lock_bh - mark the beginning of a softirq-only RCU critica=
l
>section
> *
> * This is equivalent of rcu_read_lock(), but to be used when updates
> * are being done using call_rcu_bh(). Since call_rcu_bh() callbacks
> * consider completion of a softirq handler to be a quiescent state,
> * a process in RCU read-side critical section must be protected by
> * disabling softirqs. Read-side critical sections in interrupt contex=
t
> * can use just rcu_read_lock().
> *
> */
>
>
>Last sentence being perfect :
>
>Read-side critical sections in interrupt context
>can use just rcu_read_lock().
>

Yeah, right, then it is more likely to be a bug of rcu lockdep.
Paul is looking at it.

Thanks!
