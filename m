From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [net-next-2.6 PATCH] e1000: allow option to limit number of
 descriptors down to 48 per ring
Date: Tue, 20 Jul 2010 10:12:33 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1007200938030.4488@jbrandeb-desk1.amr.corp.intel.com>
References: <20100719234219.13875.90302.stgit@localhost.localdomain> <1279600823.2458.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52285 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751046Ab0GTRMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 13:12:34 -0400
In-Reply-To: <1279600823.2458.59.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 19 Jul 2010, Eric Dumazet wrote:

> Le lundi 19 juillet 2010 =C3=A0 16:43 -0700, Jeff Kirsher a =C3=A9cri=
t :
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> >=20
> > This change makes it possible to limit the number of descriptors do=
wn to 48
> > per ring.  The reason for this change is to address a variation on =
hardware
> > errata 10 for 82546GB in which descriptors will be lost if more tha=
n 32
> > descriptors are fetched and the PCI-X MRBC is 512.
> > -#define E1000_MIN_TXD                       80
> > +#define E1000_MIN_TXD                       48
> >  #define E1000_MAX_82544_TXD               4096
> > =20
> >  #define E1000_DEFAULT_RXD                  256
> >  #define E1000_MAX_RXD                      256
> > -#define E1000_MIN_RXD                       80
> > +#define E1000_MIN_RXD                       48
> >  #define E1000_MAX_82544_RXD               4096

> So this limit is a pure software one ?

Yes, the hardware will work fine (with the exception of some limits whe=
n=20
certain performance registers are configured like [TR]XDCTL) all the wa=
y=20
down to 1 descriptor, that said, the practical limit is probably more l=
ike=20
8 for RX descriptors, and is 2 * (MAX_SKB_FRAGS + 1) for transmit if TS=
O=20
is enabled.

if all offloads are disabled you could run with only 8 tx descriptors, =
and=20
I believe it would work fine.

> Why not let an admin chose a lower limit if he wants to ?

I think in this case just to prevent odd interaction bugs with low valu=
es=20
(there would have to be several driver changes and the testing work wou=
ld=20
increase to support very low values)

> I am asking because big ring sizes can be a latency source in some
> workloads.

yes, if you are trying to pace traffic in software.  That said, at leas=
t=20
on transmit, most frames exit immediately from the hardware unless some=
=20
external event like flow control is slowing down transmit.

Jesse
