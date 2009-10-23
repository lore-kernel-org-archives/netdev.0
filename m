From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: udp: break from the lookup when hitting the maximum score value
Date: Fri, 23 Oct 2009 18:57:32 +0200
Message-ID: <4AE1E07C.5030502@gmail.com>
References: <200910231936.16022.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57213 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbZJWQ5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 12:57:43 -0400
In-Reply-To: <200910231936.16022.lgrijincu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucian Adrian Grijincu a =C3=A9crit :
> Before udp hashes were converted to rcu in
> 	udp: introduce struct udp_table and multiple spinlocks
> 	645ca708f936b2fbeb79e52d7823e3eb2c0905f8
> we stopped searching in list upon hitting the maximum score value (wh=
ich is=20
> 9).
>=20
> This got removed in the conversion to rcu.
> I'm not sure whether this was intentional or it just slipped by.
>=20
> As far as I understand it this does not interfere with the lockless r=
cu: there=20
> is another score check the result will have to pass and if it doesn't=
 have a=20
> score of 9 (which will be the value of badness) we'll just restart th=
e lookup.
>=20
> Even if the node was deleted from the chain and reclaimed at a later =
time, if=20
> at the second score test we have value 9 again, we can still return w=
ith this=20
> result.
>=20
> Am I missing something?
>=20
>=20

This was intentional.

This never happens in practice and slowdown lookups.

(To reach score 9, your UDP socket must be connected, and bound to a de=
vice)
Most developpers dont even know UDP socket can be connected...

We added large hashtables in commit f86dcc5aa8c7908f2c287e7a211228df599=
e3e71
(udp: dynamically size hash tables at boot time), so average chain leng=
th should
be small anyway...



