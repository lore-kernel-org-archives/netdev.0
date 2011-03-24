From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 23:44:12 +0100
Message-ID: <1301006652.2714.145.camel@edumazet-laptop>
References: <1301005107.2714.113.camel@edumazet-laptop>
	 <AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
	 <1301005946.2714.130.camel@edumazet-laptop>
	 <20110324.153623.45921344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alessandro.suardi@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110324.153623.45921344.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 24 mars 2011 =C3=A0 15:36 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 24 Mar 2011 23:32:26 +0100
>=20
> > Then it doesnt work anymore because it parses an ipip field from
> > ip route get ...
> >=20
> > $ ip ro get 192.168.1.1
> > 192.168.1.1 dev wlan0  src 192.168.1.21=20
> >     cache  ipid 0x784c mtu 1500 advmss 1460 hoplimit 64
> >=20
> >=20
> > Maybe you upgraded iproute2
>=20
> I'm leaning towards app bug too.
>=20
> These default metrics wouldn't get printed before, but now because of
> how metrics are handled, they will.
>=20
> Userland needs to cope properly with this.


BTW, ipip is not always printed (even on old kernels) : One needs to
actually need ipip generation .

edumazet@edumazet-laptop:~$ ping 4.4.4.4
PING 4.4.4.4 (4.4.4.4) 56(84) bytes of data.
^C

edumazet@edumazet-laptop:~$ ip ro get 4.4.4.4
4.4.4.4 dev ppp0  src 10.150.51.210=20
    cache  mtu 1500 advmss 1460 hoplimit 64

edumazet@edumazet-laptop:~$ ping -s 2000 4.4.4.4
PING 4.4.4.4 (4.4.4.4) 2000(2028) bytes of data.
^C

edumazet@edumazet-laptop:~$ ip ro get 4.4.4.4
4.4.4.4 dev ppp0  src 10.150.51.210=20
    cache  ipid 0xf99a mtu 1500 advmss 1460 hoplimit 64


This on a 2.6.35 kernel

I suspect Alessandro tool had a bug anyway.
