From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Mon, 15 Mar 2010 11:10:06 +0800
Message-ID: <2375c9f91003142010g61841666iad53c24f39036acf@mail.gmail.com>
References: <20100311134556.GA6344@linux.vnet.ibm.com>
	 <2375c9f91003112356g1b4164e4pb5f63f0e0e2f310a@mail.gmail.com>
	 <20100312.000705.225033546.davem@davemloft.net>
	 <2375c9f91003120059g771d162fxefc21beb2ab17b4d@mail.gmail.com>
	 <1268392276.3141.4.camel@edumazet-laptop>
	 <2375c9f91003120511j6f33592cl12cb2617a27351ec@mail.gmail.com>
	 <1268401058.3141.9.camel@edumazet-laptop> <20100313053356.GC3704@hack>
	 <20100313215838.GB6805@linux.vnet.ibm.com>
	 <20100315010802.GB2735@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100315010802.GB2735@hack>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/3/15 Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>:
> On Sat, Mar 13, 2010 at 01:58:38PM -0800, Paul E. McKenney wrote:
>>On Sat, Mar 13, 2010 at 01:33:56PM +0800, Am=C3=A9rico Wang wrote:
>>> On Fri, Mar 12, 2010 at 02:37:38PM +0100, Eric Dumazet wrote:
>>> >Le vendredi 12 mars 2010 =C3=A0 21:11 +0800, Am=C3=A9rico Wang a =C3=
=A9crit :
>>> >
>>> >> Oh, but lockdep complains about rcu_read_lock(), it said
>>> >> rcu_read_lock() can't be used in softirq context.
>>> >>
>>> >> Am I missing something?
>>> >
>>> >Well, lockdep might be dumb, I dont know...
>>> >
>>> >I suggest you read rcu_read_lock_bh kernel doc :
>>> >
>>> >/**
>>> > * rcu_read_lock_bh - mark the beginning of a softirq-only RCU cri=
tical
>>> >section
>>> > *
>>> > * This is equivalent of rcu_read_lock(), but to be used when upda=
tes
>>> > * are being done using call_rcu_bh(). Since call_rcu_bh() callbac=
ks
>>> > * consider completion of a softirq handler to be a quiescent stat=
e,
>>> > * a process in RCU read-side critical section must be protected b=
y
>>> > * disabling softirqs. Read-side critical sections in interrupt co=
ntext
>>> > * can use just rcu_read_lock().
>>> > *
>>> > */
>>> >
>>> >
>>> >Last sentence being perfect :
>>> >
>>> >Read-side critical sections in interrupt context
>>> >can use just rcu_read_lock().
>>> >
>>>
>>> Yeah, right, then it is more likely to be a bug of rcu lockdep.
>>> Paul is looking at it.
>>
>>Except that it seems to be working correctly for me...
>>
>
> Hmm, then I am confused. The only possibility here is that this is
> a lockdep bug...
>

I believe so...

Peter, this looks odd:

 kernel:  (usbfs_mutex){+.?...}, at: [<ffffffff8146419f>]
netif_receive_skb+0xe7/0x819

netif_receive_skb() never has a chance to take usbfs_mutex. How can thi=
s
comes out?
