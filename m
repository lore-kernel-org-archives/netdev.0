From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in
 xen-netfront/netback
Date: Thu, 15 Nov 2012 11:15:06 +0000
Message-ID: <1352978106.3499.101.camel@zakaz.uk.xensource.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	 <20121115074057.GO8912@reaktio.net> <50A4AA06.8080900@oracle.com>
	 <50A4CA51.8080208@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ANNIE LI <annie.li@oracle.com>,
	Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Roger Pau Monne <roger.pau@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:29151 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423250Ab2KOLP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 06:15:26 -0500
In-Reply-To: <50A4CA51.8080208@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 10:56 +0000, Roger Pau Monne wrote:
> On 15/11/12 09:38, ANNIE LI wrote:
> >=20
> >=20
> > On 2012-11-15 15:40, Pasi K=C3=A4rkk=C3=A4inen wrote:
> >> Hello,
> >>
> >> On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
> >>> This patch implements persistent grants for xen-netfront/netback.=
 This
> >>> mechanism maintains page pools in netback/netfront, these page po=
ols is used to
> >>> save grant pages which are mapped. This way improve performance w=
hich is wasted
> >>> when doing grant operations.
> >>>
> >>> Current netback/netfront does map/unmap grant operations frequent=
ly when
> >>> transmitting/receiving packets, and grant operations costs much c=
pu clock. In
> >>> this patch, netfront/netback maps grant pages when needed and the=
n saves them
> >>> into a page pool for future use. All these pages will be unmapped=
 when
> >>> removing/releasing the net device.
> >>>
> >> Do you have performance numbers available already? with/without pe=
rsistent grants?
> > I have some simple netperf/netserver test result with/without persi=
stent=20
> > grants,
> >=20
> > Following is result of with persistent grant patch,
> >=20
> > Guests, Sum,      Avg,     Min,     Max
> >   1,  15106.4,  15106.4, 15106.36, 15106.36
> >   2,  13052.7,  6526.34,  6261.81,  6790.86
> >   3,  12675.1,  6337.53,  6220.24,  6454.83
> >   4,  13194,  6596.98,  6274.70,  6919.25
> >=20
> >=20
> > Following are result of without persistent patch
> >=20
> > Guests, Sum,     Avg,    Min,        Max
> >   1,  10864.1,  10864.1, 10864.10, 10864.10
> >   2,  10898.5,  5449.24,  4862.08,  6036.40
> >   3,  10734.5,  5367.26,  5261.43,  5473.08
> >   4,  10924,    5461.99,  5314.84,  5609.14
>=20
> In the block case, performance improvement is seen when using a large
> number of guests, could you perform the same benchmark increasing the
> number of guests to 15?

It would also be nice to see some analysis of the numbers which justify
why this change is a good one without every reviewer having to evaluate
the raw data themselves. In fact this should really be part of the
commit message.

Ian.
