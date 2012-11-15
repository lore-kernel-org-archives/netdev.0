From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in
 xen-netfront/netback
Date: Thu, 15 Nov 2012 08:51:59 +0000
Message-ID: <1352969519.3499.30.camel@zakaz.uk.xensource.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	 <20121115074057.GO8912@reaktio.net> <50A4AA06.8080900@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:8426 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756187Ab2KOIwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:52:01 -0500
In-Reply-To: <50A4AA06.8080900@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 08:38 +0000, ANNIE LI wrote:
>=20
> On 2012-11-15 15:40, Pasi K=C3=A4rkk=C3=A4inen wrote:
> > Hello,
> >
> > On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
> >> This patch implements persistent grants for xen-netfront/netback. =
This
> >> mechanism maintains page pools in netback/netfront, these page poo=
ls is used to
> >> save grant pages which are mapped. This way improve performance wh=
ich is wasted
> >> when doing grant operations.
> >>
> >> Current netback/netfront does map/unmap grant operations frequentl=
y when
> >> transmitting/receiving packets, and grant operations costs much cp=
u clock. In
> >> this patch, netfront/netback maps grant pages when needed and then=
 saves them
> >> into a page pool for future use. All these pages will be unmapped =
when
> >> removing/releasing the net device.
> >>
> > Do you have performance numbers available already? with/without per=
sistent grants?
> I have some simple netperf/netserver test result with/without persist=
ent=20
> grants,
>=20
> Following is result of with persistent grant patch,

> Guests, Sum,      Avg,     Min,     Max
>   1,  15106.4,  15106.4, 15106.36, 15106.36
>   2,  13052.7,  6526.34,  6261.81,  6790.86
>   3,  12675.1,  6337.53,  6220.24,  6454.83
>   4,  13194,  6596.98,  6274.70,  6919.25

Are these pairs of guests or individual ones?

I think the really interesting cases are when you get up to larger
numbers of guests, aren't they? ISTR that for blkio things got most
interesting WRT persistent grants at the dozens of guests stage. Do you
have any numbers for those?

Have you run any tests other than netperf?

Do you have numbers for a a persistent capable backend with a
non-persistent frontend and vice versa?


>=20
>=20
> Following are result of without persistent patch
>=20
> Guests, Sum,     Avg,    Min,        Max
>   1,  10864.1,  10864.1, 10864.10, 10864.10
>   2,  10898.5,  5449.24,  4862.08,  6036.40
>   3,  10734.5,  5367.26,  5261.43,  5473.08
>   4,  10924,    5461.99,  5314.84,  5609.14
