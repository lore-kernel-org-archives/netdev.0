From: Alex Dubov <oakad@yahoo.com>
Subject: Re: [Bugme-new] [Bug 33042] New: Marvell 88E1145 phy configured incorrectly in fiber mode
Date: Mon, 11 Apr 2011 20:45:24 -0700 (PDT)
Message-ID: <392488.26736.qm@web37606.mail.mud.yahoo.com>
References: <4DA3703B.1090802@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Andy Fleming <afleming@freescale.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37606.mail.mud.yahoo.com ([209.191.87.89]:25209 "HELO
	web37606.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756509Ab1DLDpZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 23:45:25 -0400
In-Reply-To: <4DA3703B.1090802@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>=20
> How does your u-boot configure the part?=A0 Does it
> write any of the=20
> configuration registers, or is it just the default
> configuration set via=20
> the strapping pins?

U-boot configures this phy just like any other phy - by running a set o=
f
register assignments from phy_info_M88E1145.

Unfortunately, I don't have a datasheet for this phy and kernel does
quite a few things differently, so simply copying stuff from u-boot
does not work well (in kernel, phy initialization is broken into 3
functions, if I'm not mistaken).

Otherwise, my problem seems to be identical to the one reported some
time ago against 88E1111 phy (which resulted in the addition of
"marvell_read_status" in the first place). The problem was, as it seems
to be now, that phy is always configured in "copper" mode, instead of
driver checking for the correct "fiber" mode bits.


>=20
> In any event, you will probably have to read the
> configuration before=20
> the drivers/net/phy/marvel.c changes them.=A0 Then
> compare that to what=20
> the driver is trying to set.=A0 Then you will either
> have to override the=20
> configuration with the device tree "marvell,reg-init"
> property, or if=20
> you are not using the device tree, add a 88e1145 specific
> flag that you=20
> set when calling phy_connect().
>=20
> David Daney
>=20
