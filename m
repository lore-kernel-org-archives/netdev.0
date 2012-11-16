From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in
 xen-netfront/netback
Date: Fri, 16 Nov 2012 10:23:25 -0500
Message-ID: <20121116152325.GG22320@phenom.dumpdata.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
 <20121115074057.GO8912@reaktio.net>
 <50A4AA06.8080900@oracle.com>
 <50A4CA51.8080208@citrix.com>
 <1352978106.3499.101.camel@zakaz.uk.xensource.com>
 <20121115182928.GB22320@phenom.dumpdata.com>
 <1353006667.26243.6.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Pau Monne <roger.pau@citrix.com>,
	ANNIE LI <annie.li@oracle.com>,
	Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19572 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab2KPPXo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 10:23:44 -0500
Content-Disposition: inline
In-Reply-To: <1353006667.26243.6.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 15, 2012 at 07:11:07PM +0000, Ian Campbell wrote:
> On Thu, 2012-11-15 at 18:29 +0000, Konrad Rzeszutek Wilk wrote:
> > On Thu, Nov 15, 2012 at 11:15:06AM +0000, Ian Campbell wrote:
> > > On Thu, 2012-11-15 at 10:56 +0000, Roger Pau Monne wrote:
> > > > On 15/11/12 09:38, ANNIE LI wrote:
> > > > >=20
> > > > >=20
> > > > > On 2012-11-15 15:40, Pasi K=E4rkk=E4inen wrote:
> > > > >> Hello,
> > > > >>
> > > > >> On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
> > > > >>> This patch implements persistent grants for xen-netfront/ne=
tback. This
> > > > >>> mechanism maintains page pools in netback/netfront, these p=
age pools is used to
> > > > >>> save grant pages which are mapped. This way improve perform=
ance which is wasted
> > > > >>> when doing grant operations.
> > > > >>>
> > > > >>> Current netback/netfront does map/unmap grant operations fr=
equently when
> > > > >>> transmitting/receiving packets, and grant operations costs =
much cpu clock. In
> > > > >>> this patch, netfront/netback maps grant pages when needed a=
nd then saves them
> > > > >>> into a page pool for future use. All these pages will be un=
mapped when
> > > > >>> removing/releasing the net device.
> > > > >>>
> > > > >> Do you have performance numbers available already? with/with=
out persistent grants?
> > > > > I have some simple netperf/netserver test result with/without=
 persistent=20
> > > > > grants,
> > > > >=20
> > > > > Following is result of with persistent grant patch,
> > > > >=20
> > > > > Guests, Sum,      Avg,     Min,     Max
> > > > >   1,  15106.4,  15106.4, 15106.36, 15106.36
> > > > >   2,  13052.7,  6526.34,  6261.81,  6790.86
> > > > >   3,  12675.1,  6337.53,  6220.24,  6454.83
> > > > >   4,  13194,  6596.98,  6274.70,  6919.25
> > > > >=20
> > > > >=20
> > > > > Following are result of without persistent patch
> > > > >=20
> > > > > Guests, Sum,     Avg,    Min,        Max
> > > > >   1,  10864.1,  10864.1, 10864.10, 10864.10
> > > > >   2,  10898.5,  5449.24,  4862.08,  6036.40
> > > > >   3,  10734.5,  5367.26,  5261.43,  5473.08
> > > > >   4,  10924,    5461.99,  5314.84,  5609.14
> > > >=20
> > > > In the block case, performance improvement is seen when using a=
 large
> > > > number of guests, could you perform the same benchmark increasi=
ng the
> > > > number of guests to 15?
> > >=20
> > > It would also be nice to see some analysis of the numbers which j=
ustify
> > > why this change is a good one without every reviewer having to ev=
aluate
> > > the raw data themselves. In fact this should really be part of th=
e
> > > commit message.
> >=20
> > You mean like a nice graph, eh?
>=20
> Together with an analysis of what it means and why it is a good thing=
,
> yes.

OK, lets put that on the TODO list for the next posting. In the meantim=
e -
it sounds like you (the maintainer) are happy with the direction this i=
s going.

The other things we want to do _after_ these patches is to look at the =
Wei
Liu patches and try to address the different reviewers comments.

The neat thing about them is that they have a concept of a page pool sy=
stem.
And with persistent pages in both blkback and netback this gets more ex=
citing.


>=20
> Ian.
>=20
> >=20
> > I will run these patches on my 32GB box and see if I can give you
> > a nice PDF/jpg.
> >=20
> > >=20
> > > Ian.
> > >=20
>=20
