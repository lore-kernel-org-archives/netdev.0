From: Alex Dubov <oakad@yahoo.com>
Subject: Re: [Bugme-new] [Bug 33042] New: Marvell 88E1145 phy configured incorrectly in fiber mode
Date: Thu, 14 Apr 2011 00:59:26 -0700 (PDT)
Message-ID: <903944.53826.qm@web37604.mail.mud.yahoo.com>
References: <BANLkTikH09jMZZk1ZgeQi+HOoeFqgTpdBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Daney <ddaney@caviumnetworks.com>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Andy Fleming <afleming@freescale.com>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37604.mail.mud.yahoo.com ([209.191.87.87]:36751 "HELO
	web37604.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752378Ab1DNH71 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 03:59:27 -0400
In-Reply-To: <BANLkTikH09jMZZk1ZgeQi+HOoeFqgTpdBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Thu, 14/4/11, Andy Fleming <afleming@gmail.com> wrote:

>=20
> I've just rewritten the U-Boot code for PHY management, so
> I'd be
> interested in hearing if this breaks your board.=A0 But
> what's
> interesting to me is that, in order for U-Boot to report
> that the link
> is a "fiber" link, something had to set the TSEC_FIBER
> flag, and only
> one PHY in the public source did.=A0 This implies to me
> that your board
> isn't supported by mainline U-Boot, and suggests that
> someone may have
> modified the 88e1145 driver. Otherwise, I don't see any
> fiber-related
> differences between the U-Boot 1145 driver, and the Linux
> one.

I had not seen any difference, that's true. But the problem somehow
creeps in.

The u-boot is standard stock u-boot pulled from the recent git,
no special configuration involved.

I actually managed to make kernel transmit stuff by playing with regist=
er
values from other marvell phy varieties, but it keeps receiving garbage=
,
so the link is still not operational.

I tried to prevent kernel from reconfiguring the phy, but to no avail.
It seems very weird to me, because I did quite a lot of testing with
u-boot and network just works on that interface. However, when kernel
starts booting it suddenly looses the ability to talk to it.

I have a copper link attached to the same transceiver and it works fine
all along.

>=20
>=20
>=20
> Reading the configuration from U-Boot is
> straightforward.=A0 use the
> "mii" command to read the registers.=A0 But don't forget
> to set register
> 22 (16 - mii command only reads hex) to 1, and read all of
> the
> registers that way, too.

I have no recourse but to keep investigating.

>=20
> You will either need to add some code to detect when the
> PHY is using
> fiber, and change the phydev->port to PORT_FIBRE, or you
> will need to
> add a board-level "fixup" to change the port to PORT_FIBRE
> on your
> board.
>=20
> Then the PHY driver should use that information to do the
> right configuration.
>=20
> Andy
>=20
