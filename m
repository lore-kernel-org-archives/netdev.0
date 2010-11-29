From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inet_hash_connect: source port allocation
Date: Mon, 29 Nov 2010 20:21:27 +0100
Message-ID: <1291058487.3435.1391.camel@edumazet-laptop>
References: <4CF3DD02.90906@oracle.com>
	 <1291051560.3435.1198.camel@edumazet-laptop>  <4CF3F114.2070108@oracle.com>
	 <1291056363.3435.1338.camel@edumazet-laptop>
	 <1291057655.3435.1363.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: John Haxby <john.haxby@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51976 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403Ab0K2TVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 14:21:32 -0500
Received: by wyb28 with SMTP id 28so4772546wyb.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 11:21:31 -0800 (PST)
In-Reply-To: <1291057655.3435.1363.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 20:07 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le lundi 29 novembre 2010 =C3=A0 19:46 +0100, Eric Dumazet a =C3=A9cr=
it :
> > Le lundi 29 novembre 2010 =C3=A0 18:29 +0000, John Haxby a =C3=A9cr=
it :
> >=20
> > > Sorry,  I think I phrased my question badly.
> > >=20
> > > inet_csk_get_port() starts its search for a free port with
> > >=20
> > >      smallest_rover =3D rover =3D net_random() % remaining + low;
> > >=20
> > > whereas __inet_hash_connect() basically misses out that call to=20
> > > net_random() so you get a predictable port number.
> > >=20
> > > Is there any good reason why that is the case?
> > >=20
> >=20
> > It seems random select was done at bind() time only in commit
> > 6df716340da3a6f ([TCP/DCCP]: Randomize port selection)
> >=20
> > It probably should be done in autobind too.
> >=20
> >=20
>=20
> I'll test following patch :

Oh well, forget this, there is something about inet_sk_port_offset()
using secure_ipv4_port_ephemeral()

We want to avoid reusing same port too fast.

http://www.tcpipguide.com/free/t_TCPIPClientEphemeralPortsandClientServ=
erApplicatio-2.htm

Port is predictable only for same destination, and if no other
connections are attempted by other threads.



