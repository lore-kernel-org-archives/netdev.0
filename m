From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.38-rc1: arp triggers RTNL assertion
Date: Mon, 24 Jan 2011 13:14:02 -0800 (PST)
Message-ID: <20110124.131402.226784705.davem@davemloft.net>
References: <1295635976.2609.23.camel@edumazet-laptop>
	<20110121.130657.106806953.davem@davemloft.net>
	<1295903498.2924.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamie@audible.transient.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295903498.2924.17.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Jan 2011 22:11:38 +0100

> Le vendredi 21 janvier 2011 =E0 13:06 -0800, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 21 Jan 2011 19:52:56 +0100
>>=20
>> > Here is how I fixed this, thanks again Jamie !
>> >=20
>> > [PATCH] net: neighbour: pneigh_lookup() doesnt need RTNL
>>=20
>> Eric, I don't think we can do this.
>>=20
>> Fundamentally, any time a user operation changes the configuration
>> of the networking, we must hold the RTNL.
>>=20
>> Eliding the RTNL for lookups is fine, but for things that change
>> state it is not.
>>=20
>> I therefore think you'll need to rework the arp_ioctl() portions
>> of the commit that introduced this regression.
>>=20
>=20
> Here is a second try of the fix, thanks !
>=20
> Note : Tested with CONFIG_PROVE_RCU=3Dy
>=20
> [PATCH] net: arp_ioctl() must hold RTNL

Thanks Eric, this one looks a lot better.  I'll apply this later
tonight.
