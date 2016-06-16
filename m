From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 6/8] net: gianfar: fix old-style declaration
Date: Thu, 16 Jun 2016 11:11:45 -0700
Message-ID: <1466100705.19647.47.camel@perches.com>
References: <20160616135020.3154461-1-arnd@arndb.de>
	 <20160616135245.3198419-1-arnd@arndb.de>
	 <20160616135245.3198419-6-arnd@arndb.de>
	 <0d9320db-ae2c-03a2-eb20-e527a69c356b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Yangbo Lu <yangbo.lu@nxp.com>, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0d9320db-ae2c-03a2-eb20-e527a69c356b@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-16 at 21:02 +0300, Sergei Shtylyov wrote:
> On 06/16/2016 04:52 PM, Arnd Bergmann wrote:
> > Modern C standards expect the '__inline__' keyword to come before t=
he return
> > type in a declaration, and we get a warning for this with "make W=3D=
1":
[]
> > diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net=
/ethernet/freescale/gianfar.c
[]
> > @@ -2275,7 +2275,7 @@ static inline void gfar_tx_checksum(struct sk=
_buff *skb, struct txfcb *fcb,
> > =A0	fcb->flags =3D flags;
> > =A0}
> >=20
> > -void inline gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
> > +static inline void gfar_tx_vlan(struct sk_buff *skb, struct txfcb =
*fcb)
> =A0=A0=A0=A0You don't mention making it *static*. Though the function=
 can be *static*=A0
> indeed... the current policy also forbids *inline* in the *.c files, =
leaving=A0
> the judgement to gcc.

While mostly true, (__always_inline vs inline vs nothing),
there are many inline uses in this file that could be removed
in a separate patch rather than removing just this one.
