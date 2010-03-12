From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Fri, 12 Mar 2010 00:07:05 -0800 (PST)
Message-ID: <20100312.000705.225033546.davem@davemloft.net>
References: <20100311134556.GA6344@linux.vnet.ibm.com>
	<20100311161751.GA3804@hack>
	<2375c9f91003112356g1b4164e4pb5f63f0e0e2f310a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51802
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753859Ab0CLIGp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Mar 2010 03:06:45 -0500
In-Reply-To: <2375c9f91003112356g1b4164e4pb5f63f0e0e2f310a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Am=E9rico Wang <xiyou.wangcong@gmail.com>
Date: Fri, 12 Mar 2010 15:56:03 +0800

> Ok, after decoding the lockdep output, it looks like that
> netif_receive_skb() should call rcu_read_lock_bh() instead of rcu_rea=
d_lock()?
> But I don't know if all callers of netif_receive_skb() are in softirq=
 context.

Normally, netif_receive_skb() is invoked from softirq context.

However, via netpoll it can be invoked essentially from any context.

But, when this happens, the networking receive path makes amends such
that this works fine.  That's what the netpoll_receive_skb() check in
netif_receive_skb() is for.  That check makes it bail out early if the
call to netif_receive_skb() is via a netpoll invocation.
