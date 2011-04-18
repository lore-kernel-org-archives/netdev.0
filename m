From: Alex Dubov <oakad@yahoo.com>
Subject: Re: [Bugme-new] [Bug 33042] New: Marvell 88E1145 phy configured incorrectly in fiber mode
Date: Sun, 17 Apr 2011 23:43:10 -0700 (PDT)
Message-ID: <983551.33255.qm@web37601.mail.mud.yahoo.com>
References: <BANLkTikJ60ND7s5-jfGTBDG3BoM-294CSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Daney <ddaney@caviumnetworks.com>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37601.mail.mud.yahoo.com ([209.191.87.84]:21363 "HELO
	web37601.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752587Ab1DRGnN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 02:43:13 -0400
In-Reply-To: <BANLkTikJ60ND7s5-jfGTBDG3BoM-294CSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Sat, 16/4/11, Andy Fleming <afleming@gmail.com> wrote:

>=20
> You could probably change to use a fixed link by removing
> the
> phy-handle property from your ethernet device node, and
> adding:
> "fixed-link=3D<0 1000 1 0 0>".=A0 If that works,
> then the issue is that
> Linux is breaking something when it connects. It might be
> good enough
> for you to use fixed-link, though it would be good to
> actually find
> out what's going wrong with the PHY driver.
>=20

It seems, I found my problem. On the linux side it purely amount to thi=
s:

--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -803,7 +803,7 @@ static struct phy_driver marvell_drivers[] =3D {
                .flags =3D PHY_HAS_INTERRUPT,
                .config_init =3D &m88e1145_config_init,
                .config_aneg =3D &marvell_config_aneg,
-               .read_status =3D &genphy_read_status,
+               .read_status =3D &marvell_read_status,
                .ack_interrupt =3D &marvell_ack_interrupt,
                .config_intr =3D &marvell_config_intr,
                .driver =3D { .owner =3D THIS_MODULE },

But then I managed to accidentally put an incorrect value of the phy
interrupt into dts file and it caused all kinds of weird problems.

Shall I send a one-liner patch for the above?

