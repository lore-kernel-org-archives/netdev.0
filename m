From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including
 destination address in the hash key
Date: Thu, 05 Nov 2009 17:36:50 +0100
Message-ID: <4AF2FF22.2000805@gmail.com>
References: <4AF1EC18.9090106@ixiacom.com> <200911050104.09538.opurdila@ixiacom.com> <4AF20F02.7000601@gmail.com> <200911051825.45749.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37785 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450AbZKEQgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 11:36:48 -0500
In-Reply-To: <200911051825.45749.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :

> IIRC, we first saw this issue in VoIP tests with up to 16000 sockets =
bound on a=20
> certain port and IP addresses (each IP address is assigned to a parti=
cular=20
> interface). We need this setup in order to emulate lots of VoIP users=
 each=20
> with a different IP address and possible a different L2 encapsulation=
=2E

Interesting case indeed, is it SIP 5060 port or RTP ports ?
(I want to know how many messages per second you want to receive)

An rbtree with 16000 elements has 15 levels, its a lot, but OK
for small trafic.

>=20
> Now, as a general note I should say that our usecases can seem absurd=
 if you=20
> take them out of the network testing field :) but my _personal_ opini=
on is that=20
> a better integration between our code base and upstream code may bene=
fit both=20
> upstream and us:
>=20
> - for us it gives the ability to stay close to upstream and get all o=
f the new=20
> shiny features without painful upgrades
>=20
> - for upstream, even if most systems don't run into these scalability=
 issues=20
> now, I see that some people are moving in that direction (see the rec=
ent PPP=20
> problems); also, stressing Linux in that regard can only make the cod=
e better=20
> - as long as the approach taken is clean and sound
>=20
> - we (or our customers) use a plethora of networking devices for test=
ing so=20
> exposing Linux early to those devices can only help catching issues e=
arlier
>=20
> In short: expect more absurd patches from us :)=20

I might cook something too :)
