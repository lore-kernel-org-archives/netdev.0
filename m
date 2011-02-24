From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 24 Feb 2011 09:22:41 +0100
Message-ID: <1298535761.2814.1.camel@edumazet-laptop>
References: <AANLkTikgDsM15DO7u2SP15xx=Y_pg6JdCLrie8ACobJP@mail.gmail.com>
	 <20110131.203556.193730771.davem@davemloft.net>
	 <AANLkTimorcNAEbSpuE_dUXKuOBZDcDcGSJ2cGefniThc@mail.gmail.com>
	 <20110223.235129.02262510.davem@davemloft.net>
	 <AANLkTikE_OU_qiBUdiDP39js8jQzGqqo1FYW2uHmw3He@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mirqus@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	ratbert@faraday-tech.com
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikE_OU_qiBUdiDP39js8jQzGqqo1FYW2uHmw3He@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 24 f=C3=A9vrier 2011 =C3=A0 16:07 +0800, Po-Yu Chuang a =C3=A9=
crit :
> Hi David,
>=20
> On Thu, Feb 24, 2011 at 3:51 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Po-Yu Chuang <ratbert.chuang@gmail.com>
> > Date: Thu, 24 Feb 2011 15:27:55 +0800
> >
> >> I guess the problem is because a HW restriction that the rx buffer=
 must be
> >> 64 bits aligned. Since I cannot make rx buffer starts at offset 2 =
bytes, the
> >> IP header, TCP header and data are not 4 bytes aligned. The perfor=
mance
> >> drops drastically.
> >
> > I cannot believe that after 20 years of commodity ethernet networki=
ng
> > chips were first designed, people are still designing hardware that
> > doesn't do this right.
>=20
> Ha ha...
> Well, this restriction was removed in the later IPs of our company. :=
-p
>=20
> >
> > Just emit garbage bytes into the sub-word alignment padding if the =
chip
> > wants to word align it's DMA writes.
>=20
> Not sure what do you mean. The problem is that HW does not accept a
> base address of RX buffer which is not 8 bytes aligned.

I still dont understand the problem, maybe you should post your work as
RFC

Why not using for the first part the skb buffer (eventually copy the
first 128 bytes to get aligned IP/TCP header), and add frags for
following parts ?
