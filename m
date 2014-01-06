From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Mon, 6 Jan 2014 11:35:12 +0100
Message-ID: <20140106103512.GR31491@secunet.com>
References: <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B24D7D.6060902@windriver.com>
 <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B26553.9070103@windriver.com>
 <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B3BAD1.30205@windriver.com>
 <20131224103521.GB29716@secunet.com>
 <52BA7DE4.9070404@windriver.com>
 <20131225101104.224f9b87@vostro>
 <52BA9AEA.7050301@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Timo Teras <timo.teras@iki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46746 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbaAFKfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 05:35:15 -0500
Content-Disposition: inline
In-Reply-To: <52BA9AEA.7050301@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 25, 2013 at 04:44:26PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B412=E6=9C=8825=E6=97=A5 16:11, Timo Teras wrote:
> >On Wed, 25 Dec 2013 14:40:36 +0800
> >Fan Du<fan.du@windriver.com>  wrote:
> >
> >>>  ccing Timo
> >>>
> >>>  On 2013=E5=B9=B412=E6=9C=8824=E6=97=A5 18:35, Steffen Klassert w=
rote:
> >>>>  >  On Fri, Dec 20, 2013 at 11:34:41AM +0800, Fan Du wrote:
> >>>>>  >>
> >>>>>  >>  Subject: [PATCHv4 net-next] xfrm: Namespacify
> >>>>>  >>  xfrm_policy_sk_bundles
> >>>>>  >>
> >>>>>  >>  xfrm_policy_sk_bundles, protected by
> >>>>>  >>  net->xfrm.xfrm_policy_sk_bundle_lock should be put into ne=
tns xfrm
> >>>>>  >>  structure, otherwise xfrm_policy_sk_bundles can be corrupt=
ed from
> >>>>>  >>  different net namespace.
> >>>>  >
> >>>>  >  I'm ok with this patch, but I wonder where we use these cach=
ed
> >>>>  >  socket bundles. After a quick look I see where we add and wh=
ere we
> >>>>  >  delete them, but I can't see how we use these cached bundles=
=2E
> >>>
> >>>  Interesting
> >>>
> >>>  The per socket bundles is introduced by Timo in commit 80c802f3
> >>>  ("xfrm: cache bundles instead of policies for outgoing flows")
> >Those existed even before. I just did systematic transformation of t=
he
> >caching code to work on bundle level instead of policy level.
>=20
> Apologizes and thanks for your quick reply :)
>=20
> >>>  But one fundamental question is why not use existing flow cache
> >>>  for per socket bundles as well? then no need to create such per
> >>>  sock xdst for every packet, and also share the same flow cache
> >>>  flush mechanism.
> >It was needed when the flow cache cached policies. They explicitly
> >needed to check the socket for per-socket policy. So it made no sens=
e
> >to have anything socket related in the cache.
>=20
> I understand your concern.
>=20
> per sk bundles could be distinguished by putting per sk policy pointe=
r into
> struct flow_cache_entry, and then compare sk policy between cached po=
licy
> against with sk policy.

Most protocols cache the used routes at the sockets, so I'm not sure if
we really need to cache them in xfrm too.

Given the fact that we don't use these cached socket policy bundles,
it would be already an improvement if we would simply remove this cachi=
ng.
All we are doing here is wasting memory.

>=20
> And I also notice flow cache is global across different namespaces, b=
ut flow
> cache flush is doing a per-cpu(also global) operation, that's not fai=
r for
> slim netns as compared with fat netns which floods flow cache. Maybe =
it's
> time to make flow cache also name space aware.

Yes, making the flow cache namespace aware would be a good thing.
