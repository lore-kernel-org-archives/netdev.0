From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH] flexcan: Acknowledge all interrupt sources in the IRQ
 handler
Date: Fri, 9 Dec 2011 14:59:54 +0100
Message-ID: <20194.5210.650914.867608@ipc1.ka-ro>
References: <1323438454-6816-1-git-send-email-LW@KARO-electronics.de>
	<4EE212AE.40005@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE212AE.40005@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Marc Kleine-Budde writes:
> On 12/09/2011 02:47 PM, Lothar Wa=C3=9Fmann wrote:
> > Otherwise the handler will get stuck in an endless IRQ loop when an
> > interrupt condition occurs that is not being acked (e.g. TWRN)
>=20
> On which CPU do you have this problem?
>=20
on i.MX28.

> Seems that mx25/35 behave a bit different than mx28. But I had no tim=
e
> to dig into this, yet. BTW Wolfgang is just reworking error handling,
> can you please test his patches he recently posted on linux-can.
>=20
The ESR of i.MX25 is completely identical to the i.MX28.
You should be able to reproduce the problem when trying to send a
message to a CAN interface with the transceiver disabled.
You will get a BIT0_ERR and the TWRN bit will be asserted and never
cleared leading to an endless interrupt loop.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
