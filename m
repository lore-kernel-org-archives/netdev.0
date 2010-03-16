From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Tue, 16 Mar 2010 18:26:26 +0800
Message-ID: <2375c9f91003160326j4a088701y9f0b923a9776a39e@mail.gmail.com>
References: <20100311134556.GA6344@linux.vnet.ibm.com>
	 <1268401058.3141.9.camel@edumazet-laptop> <20100313053356.GC3704@hack>
	 <20100313215838.GB6805@linux.vnet.ibm.com>
	 <20100315010802.GB2735@hack>
	 <2375c9f91003142010g61841666iad53c24f39036acf@mail.gmail.com>
	 <2375c9f91003150239m1abc765bh59eb51c948eed592@mail.gmail.com>
	 <1268647460.3154.1.camel@edumazet-laptop>
	 <2375c9f91003150312u37dfd70fk55a4b8820e13590e@mail.gmail.com>
	 <1268649663.3154.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268649663.3154.9.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 15, 2010 at 6:41 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 15 mars 2010 =C3=A0 18:12 +0800, Am=C3=A9rico Wang a =C3=A9c=
rit :
>> On Mon, Mar 15, 2010 at 6:04 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le lundi 15 mars 2010 =C3=A0 17:39 +0800, Am=C3=A9rico Wang a =C3=A9=
crit :
>> >
>> >>
>> >> Ok, I think I found what lockdep really complains about, it is th=
at we took
>> >> spin_lock in netpoll_poll_lock() which is in hardirq-enabled envi=
ronment,
>> >> later, we took another spin_lock with spin_lock_irqsave() in netp=
oll_rx(),
>> >> so lockdep thought we broke the locking rule.
>> >>
>> >> I don't know why netpoll_rx() needs irq disabled, it looks like t=
hat no one
>> >> takes rx_lock in hardirq context. So can we use spin_lock(&rx_loc=
k)
>> >> instead? Or am I missing something here? Eric? David?
>> >
>> > I am a bit lost.
>> >
>> > Could you give the complete picture, because I cannot find it in m=
y
>> > netdev archives.
>> >
>>
>> Sure, sorry for this.
>>
>> Here is the whole thread:
>>
>> http://lkml.org/lkml/2010/3/11/100
>
> OK thanks
>
> netpoll_rx() can be called from hard irqs (netif_rx()), so rx_lock
> definitly needs irq care.
>
> netpoll_poll_lock() does take a spinlock with irq enabled, but its no=
t
> rx_lock, its napi->poll_lock.

Yeah, I knew, but besides rcu locks, these two locks are the only
locks that can be taken in the call chain. I suspect lockdep got
something wrong.

>
> I dont see what could be the problem, is it reproductible with vanill=
a
> kernel ?
>

No. I don't know why, my patch doesn't touch any function in the
call chain.

I already "fix" this in another way, so no need to worry this any more.

Thanks for your help!
