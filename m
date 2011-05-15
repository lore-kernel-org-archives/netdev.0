From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Sun, 15 May 2011 23:10:26 +0200
Message-ID: <1305493826.3120.174.camel@edumazet-laptop>
References: <20110513171729.247b126e@nehalam>
	 <1305488809.3120.162.camel@edumazet-laptop>
	 <1305490850.8178.57.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62390 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab1EOVKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 17:10:32 -0400
Received: by wwa36 with SMTP id 36so4495155wwa.1
        for <netdev@vger.kernel.org>; Sun, 15 May 2011 14:10:31 -0700 (PDT)
In-Reply-To: <1305490850.8178.57.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 15 mai 2011 =C3=A0 13:20 -0700, Joe Perches a =C3=A9crit :
> On Sun, 2011-05-15 at 21:46 +0200, Eric Dumazet wrote:
> > Le vendredi 13 mai 2011 =C3=A0 17:17 -0700, Stephen Hemminger a =C3=
=A9crit :
> > > There are some addresses in the assigned vendor block that don't =
obey
> > > the locally assigned convention. These should be avoided by rando=
m_ether_addr
> > > assignment.
> > We call random_ether_addr() for some virtual devices, maybe we can =
add a
> > __random_ether_addr() helper for them and not avoid these OUI ?
>=20
> Unless it's speed critical, it's probably not worthwhile.
>=20

Speed was not my concern, but getting idea of why avoiding pre-assigned
OUI was a concern for them, if they dont hit a real Ethernet domain.

> I think that using get_random_bytes, because it can drain
> the entropy pool, may not be a great thing to do.
>=20

This has litle to do with Stephen patch. You could discuss this with
Matt Mackall.

By the way, since 2.6.29 every exec() gets 16 bytes from
get_random_bytes() for PRNG seeding.

Typical machine starts far more programs than network interfaces ;)


Anyway, it seems to have no impact at all, even gathering 128*6 bytes
here :=20

# cat /proc/sys/kernel/random/entropy_avail
142
# modprobe dummy numdummies=3D128=20
# cat /proc/sys/kernel/random/entropy_avail
156



