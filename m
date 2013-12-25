From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Wed, 25 Dec 2013 10:11:04 +0200
Message-ID: <20131225101104.224f9b87@vostro>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
	<1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B24D7D.6060902@windriver.com>
	<1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B26553.9070103@windriver.com>
	<1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B3BAD1.30205@windriver.com>
	<20131224103521.GB29716@secunet.com>
	<52BA7DE4.9070404@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:48924 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab3LYILG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 03:11:06 -0500
Received: by mail-lb0-f172.google.com with SMTP id x18so3188241lbi.17
        for <netdev@vger.kernel.org>; Wed, 25 Dec 2013 00:11:04 -0800 (PST)
In-Reply-To: <52BA7DE4.9070404@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Dec 2013 14:40:36 +0800
=46an Du <fan.du@windriver.com> wrote:

> ccing Timo
>=20
> On 2013=E5=B9=B412=E6=9C=8824=E6=97=A5 18:35, Steffen Klassert wrote:
> > On Fri, Dec 20, 2013 at 11:34:41AM +0800, Fan Du wrote:
> >>
> >> Subject: [PATCHv4 net-next] xfrm: Namespacify
> >> xfrm_policy_sk_bundles
> >>
> >> xfrm_policy_sk_bundles, protected by
> >> net->xfrm.xfrm_policy_sk_bundle_lock should be put into netns xfrm
> >> structure, otherwise xfrm_policy_sk_bundles can be corrupted from
> >> different net namespace.
> >
> > I'm ok with this patch, but I wonder where we use these cached
> > socket bundles. After a quick look I see where we add and where we
> > delete them, but I can't see how we use these cached bundles.
>=20
> Interesting
>=20
> The per socket bundles is introduced by Timo in commit 80c802f3
> ("xfrm: cache bundles instead of policies for outgoing flows")

Those existed even before. I just did systematic transformation of the
caching code to work on bundle level instead of policy level.

> But one fundamental question is why not use existing flow cache
> for per socket bundles as well? then no need to create such per
> sock xdst for every packet, and also share the same flow cache
> flush mechanism.

It was needed when the flow cache cached policies. They explicitly
needed to check the socket for per-socket policy. So it made no sense
to have anything socket related in the cache.

> My first impression is it can be done this way, I'm going to head
> this way unless turn out otherwise.

I think it could converted. You'll still need to look up the per-socket
policies. But if caching the bundles in flow cache simplifies overall
code it sounds like a good thing to do.

- Timo
