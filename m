From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in
 xen-netfront/netback
Date: Fri, 16 Nov 2012 10:21:15 -0500
Message-ID: <20121116152115.GF22320@phenom.dumpdata.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
 <20121115074057.GO8912@reaktio.net>
 <50A4AA06.8080900@oracle.com>
 <50A4CA51.8080208@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ANNIE LI <annie.li@oracle.com>,
	Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Roger Pau =?iso-8859-1?Q?Monn=E9?= <roger.pau@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18979 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750Ab2KPPWj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 10:22:39 -0500
Content-Disposition: inline
In-Reply-To: <50A4CA51.8080208@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 15, 2012 at 11:56:17AM +0100, Roger Pau Monn=E9 wrote:
> On 15/11/12 09:38, ANNIE LI wrote:
> >=20
> >=20
> > On 2012-11-15 15:40, Pasi K=E4rkk=E4inen wrote:
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

Keep in mind that one of the things that is limiting these numbers is
that netback is very CPU intensive. So I think it could get much much
faster - but netback pegs at 100%. With Wei Liu's patches the CPU usage
did drop by 40% (this is when I tested the old netback with Wei's
netback patches)- so we should see even a further speed increase.
