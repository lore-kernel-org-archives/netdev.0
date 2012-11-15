From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in
 xen-netfront/netback
Date: Thu, 15 Nov 2012 19:11:07 +0000
Message-ID: <1353006667.26243.6.camel@dagon.hellion.org.uk>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	 <20121115074057.GO8912@reaktio.net> <50A4AA06.8080900@oracle.com>
	 <50A4CA51.8080208@citrix.com>
	 <1352978106.3499.101.camel@zakaz.uk.xensource.com>
	 <20121115182928.GB22320@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Pau Monne <roger.pau@citrix.com>,
	ANNIE LI <annie.li@oracle.com>,
	Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:16736 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1768590Ab2KOTLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 14:11:09 -0500
In-Reply-To: <20121115182928.GB22320@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 18:29 +0000, Konrad Rzeszutek Wilk wrote:
> On Thu, Nov 15, 2012 at 11:15:06AM +0000, Ian Campbell wrote:
> > On Thu, 2012-11-15 at 10:56 +0000, Roger Pau Monne wrote:
> > > On 15/11/12 09:38, ANNIE LI wrote:
> > > >=20
> > > >=20
> > > > On 2012-11-15 15:40, Pasi K=E4rkk=E4inen wrote:
> > > >> Hello,
> > > >>
> > > >> On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
> > > >>> This patch implements persistent grants for xen-netfront/netb=
ack. This
> > > >>> mechanism maintains page pools in netback/netfront, these pag=
e pools is used to
> > > >>> save grant pages which are mapped. This way improve performan=
ce which is wasted
> > > >>> when doing grant operations.
> > > >>>
> > > >>> Current netback/netfront does map/unmap grant operations freq=
uently when
> > > >>> transmitting/receiving packets, and grant operations costs mu=
ch cpu clock. In
> > > >>> this patch, netfront/netback maps grant pages when needed and=
 then saves them
> > > >>> into a page pool for future use. All these pages will be unma=
pped when
> > > >>> removing/releasing the net device.
> > > >>>
> > > >> Do you have performance numbers available already? with/withou=
t persistent grants?
> > > > I have some simple netperf/netserver test result with/without p=
ersistent=20
> > > > grants,
> > > >=20
> > > > Following is result of with persistent grant patch,
> > > >=20
> > > > Guests, Sum,      Avg,     Min,     Max
> > > >   1,  15106.4,  15106.4, 15106.36, 15106.36
> > > >   2,  13052.7,  6526.34,  6261.81,  6790.86
> > > >   3,  12675.1,  6337.53,  6220.24,  6454.83
> > > >   4,  13194,  6596.98,  6274.70,  6919.25
> > > >=20
> > > >=20
> > > > Following are result of without persistent patch
> > > >=20
> > > > Guests, Sum,     Avg,    Min,        Max
> > > >   1,  10864.1,  10864.1, 10864.10, 10864.10
> > > >   2,  10898.5,  5449.24,  4862.08,  6036.40
> > > >   3,  10734.5,  5367.26,  5261.43,  5473.08
> > > >   4,  10924,    5461.99,  5314.84,  5609.14
> > >=20
> > > In the block case, performance improvement is seen when using a l=
arge
> > > number of guests, could you perform the same benchmark increasing=
 the
> > > number of guests to 15?
> >=20
> > It would also be nice to see some analysis of the numbers which jus=
tify
> > why this change is a good one without every reviewer having to eval=
uate
> > the raw data themselves. In fact this should really be part of the
> > commit message.
>=20
> You mean like a nice graph, eh?

Together with an analysis of what it means and why it is a good thing,
yes.

Ian.

>=20
> I will run these patches on my 32GB box and see if I can give you
> a nice PDF/jpg.
>=20
> >=20
> > Ian.
> >=20
