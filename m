From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in
 xen-netfront/netback
Date: Fri, 16 Nov 2012 10:34:12 -0500
Message-ID: <20121116153412.GJ22320@phenom.dumpdata.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
 <20121115074057.GO8912@reaktio.net>
 <50A4AA06.8080900@oracle.com>
 <CAOsiSVU+9fkGQhVhnrx=xxUD8hej55XXJGpKGWAxe1USPEhiEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ANNIE LI <annie.li@oracle.com>,
	Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	netdev@vger.kernel.org,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <liuw@liuw.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41911 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065Ab2KPPec convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 10:34:32 -0500
Content-Disposition: inline
In-Reply-To: <CAOsiSVU+9fkGQhVhnrx=xxUD8hej55XXJGpKGWAxe1USPEhiEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 15, 2012 at 05:35:13PM +0800, Wei Liu wrote:
> On Thu, Nov 15, 2012 at 4:38 PM, ANNIE LI <annie.li@oracle.com> wrote=
:
>=20
> >
> >
> > On 2012-11-15 15:40, Pasi K=E4rkk=E4inen wrote:
> >
> >> Hello,
> >>
> >> On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
> >>
> >>> This patch implements persistent grants for xen-netfront/netback.=
 This
> >>> mechanism maintains page pools in netback/netfront, these page po=
ols is
> >>> used to
> >>> save grant pages which are mapped. This way improve performance w=
hich is
> >>> wasted
> >>> when doing grant operations.
> >>>
> >>> Current netback/netfront does map/unmap grant operations frequent=
ly when
> >>> transmitting/receiving packets, and grant operations costs much c=
pu
> >>> clock. In
> >>> this patch, netfront/netback maps grant pages when needed and the=
n saves
> >>> them
> >>> into a page pool for future use. All these pages will be unmapped=
 when
> >>> removing/releasing the net device.
> >>>
> >>>  Do you have performance numbers available already? with/without
> >> persistent grants?
> >>
> > I have some simple netperf/netserver test result with/without persi=
stent
> > grants,
> >
> > Following is result of with persistent grant patch,
> >
> > Guests, Sum,      Avg,     Min,     Max
> >  1,  15106.4,  15106.4, 15106.36, 15106.36
> >  2,  13052.7,  6526.34,  6261.81,  6790.86
> >  3,  12675.1,  6337.53,  6220.24,  6454.83
> >  4,  13194,  6596.98,  6274.70,  6919.25
> >
> >
> > Following are result of without persistent patch
> >
> > Guests, Sum,     Avg,    Min,        Max
> >  1,  10864.1,  10864.1, 10864.10, 10864.10
> >  2,  10898.5,  5449.24,  4862.08,  6036.40
> >  3,  10734.5,  5367.26,  5261.43,  5473.08
> >  4,  10924,    5461.99,  5314.84,  5609.14
> >
> >
> >
> Interesting results. Have you tested how good it is on a 10G nic, i.e=
=2E
> guest sending packets
> through physical network to another host.

Not yet. This was done with two guests pounding each other. I am
setting two machines up for Annie so she can do that type of testing
and also with more guests.
