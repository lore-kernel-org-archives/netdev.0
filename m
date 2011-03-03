From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re: [RFC][PATCH] Export DNSSL RA option to userspace
Date: Thu, 3 Mar 2011 02:36:49 +0100
Message-ID: <20110303013649.GA13101@via.ecp.fr>
References: <20101212150701.20d4fd6d@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pierre-list@ossman.eu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:37584 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300Ab1CCBg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 20:36:57 -0500
Content-Disposition: inline
In-Reply-To: <20101212150701.20d4fd6d@mjolnir.ossman.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I've also noticed a problem in the nduseropt code that I'm not sure h=
ow
> to solve (given that this is now a stable userspace interface). Both
> RFC5006 and RFC6106 state the following:
>=20
>    Note:  An RDNSS address or a DNSSL domain name MUST be used only a=
s
>       long as both the RA router Lifetime (advertised by a Router
>       Advertisement message [RFC4861]) and the corresponding option
>       Lifetime have not expired.
>=20
> But the RA router lifetime is not included in the information sent.
> Normally this is probably not an issue as the RDNSS and DNSSL lifetim=
e
> will be shorter than the router lifetime. One exception is when the
> router is disabled at which point it will send a RA with router
> lifetime to 0 (RFC4861 section 6.2.5). That means userspace will not =
be
> informed that the DNS information should be removed immediately*.
>=20
> Is there any way we can safely extend the interface with this
> information? I'm not familiar enough with it myself yet to determine =
if
> it's possible...

You could define a new netlink attribute to carry the lifetime of
the router in that RA. But that seems pointless to me, since in my
understanding, you have to track the lifetime of that router in future
RAs too, independently of whether or not they contain an RDNSS/DNSSL
option or not. So the nduseropt code path is not the right place to
track this.

I suppose it's possible to use a netlink socket to track events related
to the corresponding router and/or directly query its lifetime, in
the same way as any networking tool does, and remove the option when
it expires. That's what I planned to do in rdnssd, although I haven't
looked into details.

Regards,

--=20
Pierre Ynard
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
