From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace and
 a system freeze
Date: Tue, 11 Mar 2014 06:30:03 +0100
Message-ID: <20140311053003.GA32371@secunet.com>
References: <20140310014452.144b0491@north>
 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140310131909.33a3042c@north>
 <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140311014649.1716bde1@north>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	Fan Du <fan.du@windriver.com>
To: Jakub =?utf-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37733 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752514AbaCKFaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 01:30:06 -0400
Content-Disposition: inline
In-Reply-To: <20140311014649.1716bde1@north>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 01:46:49AM +0100, Jakub Kici=C5=84ski wrote:
> On Mon, 10 Mar 2014 07:04:36 -0700, Eric Dumazet wrote:
> > On Mon, 2014-03-10 at 13:19 +0100, Jakub Kici=C5=84ski wrote:
> >=20
> > > It helps with the flow_cache warning and BUG ("ip netns add" work=
s) but
> > > machine still freezes after 5-10 minutes.  I will try to revert
> > > ca925cf1534ebcec332c08719a7dee6ee1782ce4 and see if that solves i=
t.
> >=20
> > I think the other issue is separate. It might be triggered by
> > conntracking change.
>=20
> I bisected the other issue to be caused/uncovered by:
>=20
> commit 1a1ccc96abb2ed9b8fbb71018e64b97324caef53
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Wed Feb 19 10:07:34 2014 +0100
>=20
>     xfrm: Remove caching of xfrm_policy_sk_bundles
>    =20
>     We currently cache socket policy bundles at xfrm_policy_sk_bundle=
s.
>     These cached bundles are never used. Instead we create and cache
>     a new one whenever xfrm_lookup() is called on a socket policy.
>    =20
>     Most protocols cache the used routes to the socket, so let's
>     remove the unused caching of socket policy bundles in xfrm.
>    =20
>     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>=20
>=20
> Machine freezes after FLOW_HASH_RND_PERIOD (default 10 minutes).

Hm, I used this for more than a month before I pushed it upstream.
But this was without the flowcache namespace changes, maybe this
interferes with the flowcache namespace changes.

I'll look into it, thanks for reporting and bisecting!
