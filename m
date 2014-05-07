From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions
 of netlink messages
Date: Thu, 08 May 2014 00:18:57 +0200
Message-ID: <536AB151.2070804@dti2.net>
References: <CALCETrWzUQ7QjykT85ExDfX-+9eDD-D-dcxofUMPvLK=ia9arg@mail.gmail.com>	<87r44qrt8v.fsf_-_@x220.int.ebiederm.org>	<87r44pnk3c.fsf@x220.int.ebiederm.org>	<20140423.153216.1388028648299605195.davem@davemloft.net>	<87a9bbeo2o.fsf_-_@x220.int.ebiederm.org> <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vgoyal@redhat.com, ssorce@redhat.com, security@kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org, serge@hallyn.com
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:60476 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbaEGWYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 18:24:30 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v13.5.2)
	with ESMTP id md50034321318.msg
	for <netdev@vger.kernel.org>; Thu, 08 May 2014 00:18:58 +0200
In-Reply-To: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 23/04/2014 23:29, Eric W. Biederman escribi=F3:
>=20
> It is possible by passing a netlink socket to a more privileged=20
> executable and then to fool that executable into writing to the=20
> socket data that happens to be valid netlink message to do something=20
> that privileged executable did not intend to do.
>=20
> To keep this from happening replace bare capable and ns_capable calls
> with netlink_capable, netlink_net_calls and netlink_ns_capable calls.
> Which act the same as the previous calls except they verify that the
> opener of the socket had the desired permissions as well.
>=20

	Hi, after this patch, zebra daemon of quagga in Debian testing fails t=
o
send routes to kernel with an -EPERM error.
	Reverting this patch and commit a64d90fd96 (netfilter: Fix warning in
nfnetlink_receive().) fixes it for me.

	I haven't got time to do a proper analisys and could be that zebra
it's doing something silly but this patch seems to subtly change some
semantics.

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
- There is only so much duct tape you can put on something
  before it just becomes a giant ball of duct tape.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
