From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 2/3] net: fec: convert to using gpiod framework
Date: Mon, 30 Nov 2015 10:17:32 -0200
Message-ID: <CAOMZO5BF=V2Q6BT17UHvx=QzupDaC1d=negP1URP4kaWZg9eAA@mail.gmail.com>
References: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
	<1448883168-30742-2-git-send-email-LW@KARO-electronics.de>
	<1448883168-30742-3-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Nimrod Andy <B38611@freescale.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Stefan Agner <stefan@agner.ch>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
To: =?UTF-8?Q?Lothar_Wa=C3=9Fmann?= <LW@karo-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448883168-30742-3-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 9:32 AM, Lothar Wa=C3=9Fmann <LW@karo-electroni=
cs.de> wrote:

> -       gpio_set_value_cansleep(phy_reset, 1);
> +       gpiod_set_value_cansleep(phy_reset, 1);

This will break some existing DTBs.

Currently the fec driver does not care whether 'phy-reset-gpios' is
active low or active high. (Yes, it was a mistake to assume in the
driver that it is always active low.)

After this change the polarity will be taken into account and may
break some dtb's.

I suggest you to send a single patch with the minimum changes to fix
the regression caused by 8fff755e9f8d ("net: fec: Ensure clocks are
enabled while using mdio bus").
