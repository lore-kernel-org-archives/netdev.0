From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Fri, 12 Mar 2010 12:11:16 +0100
Message-ID: <1268392276.3141.4.camel@edumazet-laptop>
References: <20100311134556.GA6344@linux.vnet.ibm.com>
	 <20100311161751.GA3804@hack>
	 <2375c9f91003112356g1b4164e4pb5f63f0e0e2f310a@mail.gmail.com>
	 <20100312.000705.225033546.davem@davemloft.net>
	 <2375c9f91003120059g771d162fxefc21beb2ab17b4d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	peterz@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:54477 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284Ab0CLLLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 06:11:23 -0500
In-Reply-To: <2375c9f91003120059g771d162fxefc21beb2ab17b4d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 12 mars 2010 =C3=A0 16:59 +0800, Am=C3=A9rico Wang a =C3=A9=
crit :
> On Fri, Mar 12, 2010 at 4:07 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>
> > Date: Fri, 12 Mar 2010 15:56:03 +0800
> >
> >> Ok, after decoding the lockdep output, it looks like that
> >> netif_receive_skb() should call rcu_read_lock_bh() instead of rcu_=
read_lock()?
> >> But I don't know if all callers of netif_receive_skb() are in soft=
irq context.
> >
> > Normally, netif_receive_skb() is invoked from softirq context.
> >
> > However, via netpoll it can be invoked essentially from any context=
=2E
> >
> > But, when this happens, the networking receive path makes amends su=
ch
> > that this works fine.  That's what the netpoll_receive_skb() check =
in
> > netif_receive_skb() is for.  That check makes it bail out early if =
the
> > call to netif_receive_skb() is via a netpoll invocation.
> >
>=20
> Oh, I see. This means we should call rcu_read_lock_bh() instead.
> If Paul has no objections, I will send a patch for this.
>=20

Nope, its calling rcu_read_lock() from interrupt context and it should
stay as is (we dont need to disable bh, this has a cpu cost)



