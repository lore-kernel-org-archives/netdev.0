From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Thu, 17 Feb 2011 07:39:08 +0100
Message-ID: <1297924748.2645.25.camel@edumazet-laptop>
References: <20110217044917.GA2653@cr0.nay.redhat.com>
	 <AANLkTikkro-_9pv5uJ4+SqYh9Fr480_96Wh1Pv6Pvtez@mail.gmail.com>
	 <20110217054237.GB2653@cr0.nay.redhat.com>
	 <20110216.214625.189707123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, cypher.w@gmail.com,
	linux-kernel@vger.kernel.org, cmetcalf@tilera.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110216.214625.189707123.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 16 f=C3=A9vrier 2011 =C3=A0 21:46 -0800, David Miller a =C3=
=A9crit :
> From: Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>
> Date: Thu, 17 Feb 2011 13:42:37 +0800
>=20
> > On Thu, Feb 17, 2011 at 01:04:14PM +0800, Cypher Wu wrote:
> >>>
> >>> Have you turned CONFIG_LOCKDEP on?
> >>>
> >>> I think Eric already converted that rwlock into RCU lock, thus
> >>> this problem should disappear. Could you try a new kernel?
> >>>
> >>> Thanks.
> >>>
> >>
> >>I haven't turned CONFIG_LOCKDEP on for test since I didn't get too
> >>much information when we tried to figured out the former deadlock.
> >>
> >>IGMP used read_lock() instead of read_lock_bh() since usually
> >>read_lock() can be called recursively, and today I've read the
> >>implementation of MIPS, it's should also works fine in that situati=
on.
> >>The implementation of TILEPro cause problem since after it use TNS =
set
> >>the lock-val to 1 and hold the original value and before it re-set
> >>lock-val a new value, it a race condition window.
> >>
> >=20
> > I see no reason why you can't call read_lock_bh() recursively,
> > read_lock_bh() is roughly equalent to local_bh_disable() + read_loc=
k(),
> > both can be recursive.
> >=20
> > But I may miss something here. :-/
>=20
> IGMP is doing this so that taking the read lock does not stop packet
> processing.
>=20
> TILEPro's rwlock implementation is simply buggy and needs to be fixed=
=2E

Yep. Finding all recursive readlocks in kernel and convert them to
another locking model is probably more expensive than fixing TILEPro
rwlock implementation.
