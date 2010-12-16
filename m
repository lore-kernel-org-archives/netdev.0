From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Fri, 17 Dec 2010 00:31:45 +0100
Message-ID: <1292542305.2655.25.camel@edumazet-laptop>
References: <1292428252.3427.342.camel@edumazet-laptop>
	 <20101216211744.GA2191@del.dom.local>
	 <1292535039.2655.13.camel@edumazet-laptop>
	 <20101216220838.GB2191@del.dom.local>
	 <1292538363.2655.20.camel@edumazet-laptop>
	 <20101216224237.GC2191@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43982 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885Ab0LPXbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 18:31:52 -0500
Received: by mail-wy0-f174.google.com with SMTP id 28so95858wyb.19
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 15:31:52 -0800 (PST)
In-Reply-To: <20101216224237.GC2191@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 23:42 +0100, Jarek Poplawski a =C3=
=A9crit :
> On Thu, Dec 16, 2010 at 11:26:03PM +0100, Eric Dumazet wrote:
> > Le jeudi 16 d=C3=A9cembre 2010 ?? 23:08 +0100, Jarek Poplawski a =C3=
=A9crit :
> >=20
> > > Hmm... Do you expect more people start debugging SFQ or I missed =
your
> > > point? ;-) Maybe such a change would be reasonable on a cloned sk=
b?
> >=20
> > My point was to permit an admin to check his ingress shaping works =
or
> > not. In this respect, netem was a specialization of a general probl=
em.
> >=20
> > We had a prior discussion on timestamping skb in RX path, when RPS =
came
> > in : Should we take timestamp before RPS or after. At that time we =
added
> > a sysctl. Not sure it was the right choice :-(
> >=20
> > I feel tcpdump (on TX side) should really display time of packet ri=
ght
> > before being given to device, but this is probably a matter of tast=
e.
>=20
> It might be reasonable unless it changes data for later users. That's
> why I mentioned cloning.
>=20
> >=20
> > Before commit 8caf153974f2 (net: sch_netem: Fix an inconsistency in
> > ingress netem timestamps.), this is what was done.
>=20
> Then why don't you try to let turn it off in netem, where it only
> matters?
>=20

Because, if you read again my patch, you'll see :

#ifdef CONFIG_NET_CLS_ACT
       if (!skb->tstamp.tv64 || (G_TC_FROM(skb->tc_verd) & AT_INGRESS))
                net_timestamp_set(skb);
#else

So :=20

If we are handling an INGRESS packet, we force a timestamp renew.

Therefore :

We dont need in netem_dequeue() to force :

-#ifdef CONFIG_NET_CLS_ACT
-                       /*
-                        * If it's at ingress let's pretend the delay i=
s
-                        * from the network (tstamp will be updated).
-                        */
-                       if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
-                               skb->tstamp.tv64 =3D 0;
-#endif

Since :

We are going to renew timestamp anyway.

Conclusion :

I am eliminating dead code.

Is that OK ?

Thanks


