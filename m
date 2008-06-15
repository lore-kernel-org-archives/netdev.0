From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCH][ATM] iphase: BUG: sleeping function called from invalid
 context
Date: Sun, 15 Jun 2008 15:00:48 +0200
Message-ID: <48551280.1090706@dti2.net>
References: <200806142105.m5EL5T49003929@cmf.nrl.navy.mil>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:2393 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757355AbYFONA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 09:00:56 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50014067443.msg
	for <netdev@vger.kernel.org>; Sun, 15 Jun 2008 15:00:53 +0200
In-Reply-To: <200806142105.m5EL5T49003929@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chas Williams (CONTRACTOR) escribi=F3:
> In message <4848106F.30503@dti2.net>,"Jorge Boncompte [DTI2]" writes:
>> 	iphase driver calls ioremap under spinlock_irqsave in his
>> initialization function. The spinlock seems to be there just for the=
=20
>> sole purpose of preventing initializing multiple cards at once. So I=
=20
>> think that removing it should be fine.
>=20
> the lock is necessary to prevent multiple cards from modifying iadev_=
count
> at the wrong time since iadev_count is incremented and decremented.
> it might be simpler to just make a local copy of iadev_count and just
> always increment iadev_count.  if you fail to init a particular card,
> you will just leave a hole in ia_dev[].  something like the attached.

	I thought that device initialization inside a driver is serialized. is=
n't it?

> also, ia_remove_one() is broken since it assumes that the cards will =
be
> removed in the same order that they were installed.
>=20
> even better would be to rewrite this to avoid the iadev[] array entir=
ely
> and use a linked list.
>=20

	I have a patch that removes iadev and iadev_count enterely that i did =
not sent because i thought it wouldn't be=20
considered a bug fix. I'll sent it this week.

	Thanks for your review,

	-Jorge
--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Jorge Boncompte - Ingenieria y Gestion de RED
DTI2 - Desarrollo de la Tecnologia de las Comunicaciones
--------------------------------------------------------------
C/ Abogado Enriquez Barrios, 5   14004 CORDOBA (SPAIN)
Tlf: +34 957 761395 / FAX: +34 957 450380
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
- Sin pistachos no hay Rock & Roll...
- Without wicker a basket cannot be made.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

