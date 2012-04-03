From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Tue, 03 Apr 2012 03:53:17 +0200
Message-ID: <1333417997.18626.1.camel@edumazet-glaptop>
References: <1333398660-11552-1-git-send-email-levinsasha928@gmail.com>
	 <201204022201.41808.remi@remlab.net>
	 <20120402.174006.70116829696492189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi@remlab.net, levinsasha928@gmail.com,
	remi.denis-courmont@nokia.com, davej@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120402.174006.70116829696492189.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-02 at 17:40 -0400, David Miller wrote:
> From: "R=C3=A9mi Denis-Courmont" <remi@remlab.net>
> Date: Mon, 2 Apr 2012 22:01:40 +0300
>=20
> > Le lundi 2 avril 2012 23:31:00 Sasha Levin, vous avez =C3=A9crit :
> >> A phonet packet is limited to USHRT_MAX bytes, this is never check=
ed during
> >> tx which means that the user can specify any size he wishes, and t=
he kernel
> >> will attempt to allocate that size.
> >=20
> > Does this really solve the problem?  I guess 128kb is still possibl=
e with=20
> > USHRT_MAX plus skbuff overhead, which might still trigger OOM relat=
ively=20
> > easily once the memory gets sufficiently fragmented.
> >=20
> > How does UDP deal with this?
>=20
> UDP generates a fragment list of MTU sized SKBs.
>=20
> Phonet could avoid the large allocations by building page based
> SKBs.

Not that AF_UNIX does nothing in this respect, it can use order-XX page=
s
for large datagrams.

(I beleve I sent a patch some time ago to address this point)
