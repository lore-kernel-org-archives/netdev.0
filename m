From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: Bug in net/ipv6/ip6_fib.c:fib6_dump_table()
Date: Fri, 22 Jun 2012 11:34:08 +0800
Message-ID: <4FE3E7B0.3020802@cn.fujitsu.com>
References: <CAATkVEzTxT6d5nzt_qwCuFWM-WcN8hdhjGxFRPXJ4=L35wKbGw@mail.gmail.com> <4FE37783.9000409@akamai.com> <1340310469.4604.6702.camel@edumazet-glaptop> <20120621215056.GA24908@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Josh Hunt <johunt@akamai.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	Debabrata Banerjee <dbavatar@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120621215056.GA24908@ms2.inr.ac.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8822=E6=97=A5 05:50, Alexey Kuznetsov =E5=
=86=99=E9=81=93:
> On Thu, Jun 21, 2012 at 10:27:49PM +0200, Eric Dumazet wrote:
>> Looking at this code, it lacks proper synchronization
>> between tree updaters and tree walkers.
>>
>> fib6_walker_lock rwlock is not enough to prevent races.
>=20
> Hmm. As author of this weird code, I must say I honestly believed it =
was correct.
> At least I tried. :-)
>=20
>=20
> What's about 2bec5a336.., it does not look reasonable.
> The idea was that when you change tree, you fixup sleeping walkers, m=
oving
> their location in tree to correct point. So, walkers must not have an=
y stale pointers
> at any times (except when you under table write lock) and no skips/co=
unts are required.
> I remember how damn difficult was it to make this right (well, sorry,=
 if it is not yet :-)),
> so that understand that if some update is forgotten or done incorrect=
ly, it is not so easy to find,
> but it is definitely worth of efforts.


Actually, I spent two months to try to reproduce this crash four months=
 ago,
But finally I give up, I don't think there was any stale pointers,
we already correct it when we change the tree.
