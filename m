From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: r8169: fix driver drop incoming packets >= 1515 if MTU is set
	between 1515 and 1536
Date: Wed, 11 Nov 2009 20:15:36 +0000
Message-ID: <1257970536.2839.73.camel@achroite.uk.solarflarecom.com>
References: <4AFB0061.7020908@apollo.lv>
	 <1257964419.2839.58.camel@achroite.uk.solarflarecom.com>
	 <4AFB190F.2020009@apollo.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Raimonds Cicans <ray@apollo.lv>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16832 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757266AbZKKUPd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 15:15:33 -0500
In-Reply-To: <4AFB190F.2020009@apollo.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-11 at 22:05 +0200, Raimonds Cicans wrote:
> Ben Hutchings:
> > On Wed, 2009-11-11 at 20:20 +0200, Raimonds Cicans wrote:
> >> Driver drop incoming packets >=3D 1515(1) if MTU is set between 15=
15(1) and 1536.
> >>
> >> 1) exact number depends on some factors:
> >> - VLAN tagged or not
> >> - patch "r8169: Fix card drop incoming VLAN tagged MTU byte large =
jumbo frames"
> >>   applied or not
> > [...]
> >=20
> > MTU is a limit on transmission; it is not required to limit receive=
d
> > frames.
>=20
> ???
>=20
> In r8169 driver MTU is used to calculate receive buffer size.
> Receive buffer size is used to configure hardware incoming packet fil=
ter.
>=20
> For jumbo frames:
> Receive buffer size =3D Max frame size =3D MTU + 14 (ethernet header)=
 + 4
> (vlan header) + 4 (ethernet checksum) =3D MTU + 22
>=20
> Bug:
> driver for all MTU up to 1536 use receive buffer size 1536
[...]

OK, now I understand.  =EF=BB=BFThe subject line you used is not gramma=
tical and
I originally thought you considered it a bug that the driver might
accept packets with payload greater than MTU.

To make it clear, perhaps you could change the subject to:
'r8169: Fix receive buffer length when MTU is between 1515 and 1536'
and then explain the current behaviour below that.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

