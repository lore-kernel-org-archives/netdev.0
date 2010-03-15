From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Mon, 15 Mar 2010 18:12:29 +0800
Message-ID: <2375c9f91003150312u37dfd70fk55a4b8820e13590e@mail.gmail.com>
References: <20100311134556.GA6344@linux.vnet.ibm.com>
	 <1268392276.3141.4.camel@edumazet-laptop>
	 <2375c9f91003120511j6f33592cl12cb2617a27351ec@mail.gmail.com>
	 <1268401058.3141.9.camel@edumazet-laptop> <20100313053356.GC3704@hack>
	 <20100313215838.GB6805@linux.vnet.ibm.com>
	 <20100315010802.GB2735@hack>
	 <2375c9f91003142010g61841666iad53c24f39036acf@mail.gmail.com>
	 <2375c9f91003150239m1abc765bh59eb51c948eed592@mail.gmail.com>
	 <1268647460.3154.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:53913 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964792Ab0COKMa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 06:12:30 -0400
In-Reply-To: <1268647460.3154.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 15, 2010 at 6:04 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 15 mars 2010 =C3=A0 17:39 +0800, Am=C3=A9rico Wang a =C3=A9c=
rit :
>
>>
>> Ok, I think I found what lockdep really complains about, it is that =
we took
>> spin_lock in netpoll_poll_lock() which is in hardirq-enabled environ=
ment,
>> later, we took another spin_lock with spin_lock_irqsave() in netpoll=
_rx(),
>> so lockdep thought we broke the locking rule.
>>
>> I don't know why netpoll_rx() needs irq disabled, it looks like that=
 no one
>> takes rx_lock in hardirq context. So can we use spin_lock(&rx_lock)
>> instead? Or am I missing something here? Eric? David?
>
> I am a bit lost.
>
> Could you give the complete picture, because I cannot find it in my
> netdev archives.
>

Sure, sorry for this.

Here is the whole thread:

http://lkml.org/lkml/2010/3/11/100
