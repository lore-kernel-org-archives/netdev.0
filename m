From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Mon, 16 Aug 2010 12:36:07 -0700 (PDT)
Message-ID: <20100816.123607.57459160.davem@davemloft.net>
References: <20100814.220945.232761341.davem@davemloft.net>
	<1281869722.2942.20.camel@edumazet-laptop>
	<1281883637.2942.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281883637.2942.42.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 Aug 2010 16:47:17 +0200

> Le dimanche 15 ao=FBt 2010 =E0 12:55 +0200, Eric Dumazet a =E9crit :
>=20
>> We have one lock per cpu, and only one cpu can possibly lock its
>> associated lock under softirq. So the usual lockdep check, warning a
>> lock is taken with BH enabled, while same lock was taken inside soft=
irq
>> handler is triggering a false positive here.
>>=20
>> I believe no existing lockdep annotation can instruct lockdep this u=
se
>> is OK, I guess we have following choice :
>>=20
>> 1) Mask BH again, using xt_info_wrlock_lockdep(cpu) instead of
>> xt_info_wrlock(cpu).
>>=20
>> xt_info_wrlock_lockdep() being a variant, that disables BH in case
>> CONFIG_PROVE_LOCKING=3Dy
>>=20
>> 2) temporally switch off lockdep in get_counters(), using a
>> lockdep_off()/lockdep_on() pair, and a comment why this is necessary=
=2E
>>=20
>=20
> In any case, here is patch implementing the later

I'm hesistent to say that we should put this kind of patch in.

It will shut up lockdep for this specific case, but it also means
that if we do any other kinds of locking in this sequence we will
not validate it.

The valuable of this is open for debate I guess.

But locking is hard so I would say that disabling lockdep to kill a
warning it generates should be an absolute last resort.

I also don't think making the locking mechanics conditional upon
LOCKDEP is sane either, exactly because it means lockdep is testing
something other than what actually gets used in practice. :-)
