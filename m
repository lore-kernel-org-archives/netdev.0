From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 20:43:36 +0200
Message-ID: <1271875416.7895.3033.camel@edumazet-laptop>
References: <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
	 <1271808314.7895.614.camel@edumazet-laptop>
	 <20100421003022.GA3107@ioremap.net>
	 <1271828799.7895.1287.camel@edumazet-laptop>
	 <20100421082559.GA32475@ioremap.net>
	 <1271840535.7895.1612.camel@edumazet-laptop>
	 <20100421095812.GA14778@ioremap.net>
	 <1271849253.7895.1929.camel@edumazet-laptop>
	 <20100421182723.GA17202@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:49763 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166Ab0DUSnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 14:43:47 -0400
Received: by bwz1 with SMTP id 1so10518029bwz.2
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 11:43:46 -0700 (PDT)
In-Reply-To: <20100421182723.GA17202@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 22:27 +0400, Evgeniy Polyakov a =C3=A9=
crit :
> On Wed, Apr 21, 2010 at 01:27:33PM +0200, Eric Dumazet (eric.dumazet@=
gmail.com) wrote:
> > Here is the patch I use now and my test application is now able to =
open
> > and connect 1000000 sockets (ulimit -n 1000000)
> >=20
> > Trick is bind_conflict() must refuse a socket to bind to a port on =
a non
> > null IP if another socket already uses same port on same IP.
> >=20
> > Plus the previous patch sent (check a conflict before exiting the s=
earch
> > loop)
> >=20
> > What do you think ?
>=20
> Looks good, but do we want to check only reused socket's address ther=
e?
> What if one of the sockets does not have reuse option turned on, will=
 it
> break?
>=20

Well, if one socket doesnt have reuse option turned on, the previous
test already works ?

if (!reuse || !sk2->sk_reuse || sk2->sk_state =3D=3D TCP_LISTEN) {
	if (!sk2_rcv_saddr || !sk_rcv_saddr ||
	    sk2_rcv_saddr =3D=3D sk_rcv_saddr)
		break;
} else if (reuse && sk2->sk_reuse &&
           sk2_rcv_saddr &&
           sk2_rcv_saddr =3D=3D sk_rcv_saddr)
	break;

I failed to factorize this complex test :(



