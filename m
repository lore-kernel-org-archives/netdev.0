From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: oops during unregister_netdevice interface enslaved to
 bond - regression
Date: Tue, 10 May 2011 15:03:33 +0200
Message-ID: <1305032613.2614.26.camel@edumazet-laptop>
References: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com>
	 <1305017672.2614.9.camel@edumazet-laptop>
	 <1305017959.2614.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Frank Blaschka <Frank.Blaschka@de.ibm.com>
To: Einar EL Lueck <ELELUECK@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44456 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659Ab1EJNDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 09:03:38 -0400
Received: by wya21 with SMTP id 21so4649343wya.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 06:03:37 -0700 (PDT)
In-Reply-To: <1305017959.2614.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 10:59 +0200, Eric Dumazet a =C3=A9crit :
> Le mardi 10 mai 2011 =C3=A0 10:54 +0200, Eric Dumazet a =C3=A9crit :
>=20
> > I am currently working on this stuff [adding even more batching and
> > probably bugs as well ], so instead of revert I'll try to find a wa=
y to
> > fix this.
> >=20
> > If you already have a script to reproduce the bug on virtual device=
s on
> > x86 (not on s390 machines I dont have ;) ), I'll appreciate having =
a
> > copy of it.
> >=20
> > Thanks for the reminder.
>=20
> BTW make sure latest linux-2.6 still exhibits the problem, we fixed s=
ome
> things after original Octavian commit
>=20
> List of commits :
>=20
> commit ceaaec98ad99859ac90ac6863ad0a6cd075d8e0e
> net: deinit automatic LIST_HEAD
>=20
> commit f87e6f47933e3ebeced9bb12615e830a72cedce4=20
> net: dont leave active on stack LIST_HEAD=20
>=20
>=20

OK I trigger the bug on linux-2.6 with :

modprobe bonding
ip link add testa type veth peer name testb
ifconfig bond0 up
ifenslave bond0 testa
ip link del testa

I'll cook a patch, stay tuned :)


