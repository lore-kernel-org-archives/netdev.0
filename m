From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kenel level packet capturing
Date: Wed, 14 Dec 2011 10:56:56 +0100
Message-ID: <1323856616.2334.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
	 <20111019123733.GA21324@synalogic.ca>
	 <CAKj1SsOra7u21u8Zq9rDLzv_Bhx8sPsah+SHByMYQbVc_j6LQA@mail.gmail.com>
	 <20111213.133629.1213042365300662857.davem@davemloft.net>
	 <4EE86DB6.5050303@fox-it.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"raviraj.j1991@gmail.com" <raviraj.j1991@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52279 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673Ab1LNJ5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 04:57:03 -0500
Received: by wgbdr13 with SMTP id dr13so1497571wgb.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 01:57:02 -0800 (PST)
In-Reply-To: <4EE86DB6.5050303@fox-it.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 d=C3=A9cembre 2011 =C3=A0 10:34 +0100, Jasper Spaans a =C3=
=A9crit :
> On 13/12/11 19:36, David Miller wrote:
> > We have decided to use PF_RING(a kernel module to capture packets) =
for
> > the same due to the number of advantages.
> > What "advantages"?  The AF_PACKET socket layer already upstream in =
the
> > kernel supports every relevant performance feature PF_RING does, an=
d
> > then some.
> Some documentation for fanout is one feature that would be nice. (How=
 to
> use it from userspace - after 5 minutes of googling, the first place
> where I could find an example is in the suricata source code[1]).
>=20
> Having not tested it in practice, so my assumptions about rxhash migh=
t
> be untrue: is there an option to override the NIC rxhash
> implementations? if you are doing packet capturing, you will probably
> see traffic in both directions, so hashing on the address-tuples of b=
oth
> directions makes sense (or else both half-streams of tcp packets migh=
t
> end up being sent to different sockets.
>=20

Disabling NIC rxhash is possible :

# ethtool -k eth2 | grep receive-hashing
receive-hashing: on
# ethtool -K eth2 rxhash off
# ethtool -k eth2 | grep receive-hashing
receive-hashing: off

> It seems hardware vendors are focussed on only hashing the senders
> address, which does make sense if you're building a
> fileserver/webserver/whatever.
>=20
> We ended up using atrocious bpfs like "((tcp[0:2] & 1) =3D=3D (tcp[2:=
2] &
> 1)) and tcp" to distribute packets over multiple sockets, and now our
> bottleneck has shifted away from the capturing side of our applicatio=
n.

If you want to distribute load on tcp sockets, you can take a look at
various tricks documented in Documentation/networking/scaling.txt

(RPS, RFS, ...)


> (Note to Raviraj: we're not using PF_RING because of stability issues=
 -
> it crashed our testing system one too many times.)
>=20
> Cheers,
> Jasper
>=20
> [1]
> https://redmine.openinfosecfoundation.org/embedded/suricata/source-af=
-packet_8c-source.html#l00516
>=20
