From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 18:38:56 +0100
Message-ID: <1321551536.2751.87.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EC2CA52.6020104@icdsoft.com>
	 <1321391355.2602.0.camel@edumazet-laptop> <4EC439F2.3080809@icdsoft.com>
	 <20111116223330.08de9e52@asterix.rh> <4EC4C160.6010804@icdsoft.com>
	 <20111117111145.252924f5@asterix.rh>
	 <1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117133724.59684d28@asterix.rh>
	 <1321547510.2751.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117144038.61b0525b@asterix.rh>
	 <1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117150145.25e01a75@asterix.rh>
	 <1321550302.2751.81.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49849 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab1KQRjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 12:39:00 -0500
Received: by wyh11 with SMTP id 11so2306499wyh.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 09:38:59 -0800 (PST)
In-Reply-To: <1321550302.2751.81.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 18:18 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le jeudi 17 novembre 2011 =C3=A0 15:01 -0200, Flavio Leitner a =C3=A9=
crit :
>=20
> > Right, so the loop trying different oif and saddr isn't working at
> > all because __ip_route_output_key() will create a route in the firs=
t
> > attempt.  Looks like you're right and we need the 'create' paramete=
r
> > in __ip_route_output_key().
>=20
> And we have to loop on all possible keys combinations.
>=20
> (like code before David commit (f39925dbde77 ipv4: Cache learned
> redirect information in inetpeer.) : it had a goto do_next;
>=20
> I am preparing a patch.
>=20


Unfortunately its not enough.

=46or some reason, ipv4_dst_check() is not called later, so we cant cal=
l
ipv4_dst_check() and change=20
rt->rt_gateway =3D peer->redirect_learned.a4;

dst->obsolete strikes again.
