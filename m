From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] The new jhash implementation
Date: Thu, 25 Nov 2010 15:05:46 +0100
Message-ID: <1290693946.2858.323.camel@edumazet-laptop>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu>
	 <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
	 <1290690908-794-3-git-send-email-kadlec@blackhole.kfki.hu>
	 <1290692943.2858.303.camel@edumazet-laptop>
	 <AANLkTi=jqRY18Omv2Y2a1XjT-SH8W--wJ7A4y4PV1oT1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=jqRY18Omv2Y2a1XjT-SH8W--wJ7A4y4PV1oT1@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 novembre 2010 =C3=A0 21:55 +0800, Changli Gao a =C3=A9crit =
:

> > I suggest :
> >
> > #include <linux/unaligned/packed_struct.h>
> > ...
> >        a +=3D __get_unaligned_cpu32(k);
> >        b +=3D __get_unaligned_cpu32(k+4);
> >        c +=3D __get_unaligned_cpu32(k+8);
> >
> > Fits nicely in registers.
> >
>=20
> I think you mean get_unaligned_le32().
>=20

No, I meant __get_unaligned_cpu32()

We do same thing in jhash2() :

	a +=3D k[0];=20
	b +=3D k[1];
	c +=3D k[2];

We dont care of bit order of the 32bit quantity we are adding to a,b or
c , as long its consistent for the current machine ;)

get_unaligned_le32() would be slow on big endian arches.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
