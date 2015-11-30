From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: fix enet_out clock handling
Date: Mon, 30 Nov 2015 03:07:31 +0100
Message-ID: <20151130020731.GB32662@lunn.ch>
References: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Nimrod Andy <B38611@freescale.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Stefan Agner <stefan@agner.ch>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47329 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836AbbK3CHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2015 21:07:46 -0500
Content-Disposition: inline
In-Reply-To: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 27, 2015 at 02:39:10PM +0100, Lothar Wa=DFmann wrote:
> When ENET_OUT is being used as reference clock for an external PHY,
> the clock must not be disabled while the PHY is active. Otherwise the
> PHY may lose its internal state and require a reset to become
> functional again.
>=20
> A symptom for this bug is a network interface that constantly toggles
> between UP and DOWN state:
> fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow control =
rx/tx
> fec 800f0000.ethernet eth0: Link is Down
> fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow control =
rx/tx
> fec 800f0000.ethernet eth0: Link is Down

Hi Lothar

When does this up/down happen? During normal operation when the link
is administrative up?

When did this start happening? Did it happen before=20
8fff755e9f8d net: fec: Ensure clocks are enabled while using mdio bus

	     Andrew
