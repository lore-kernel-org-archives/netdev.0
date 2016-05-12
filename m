From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [RFC] Reset pins of phys and their representation in a device tree
Date: Thu, 12 May 2016 09:15:42 +0200
Message-ID: <20160512071542.GC30822@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47159 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181AbcELHPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 03:15:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a machine here where the reset pin of the phy is connected to a
GPIO.

There are different possibilities available today to handle this
situation, here are the ones I'm aware of:

 - Use a gpio-hog to set the reset gpio to non-active
   This might result in dependency problems (and that's what I am
   currently faced with) because there is no connection in the device
   tree between the hog and the phy.

 - [Documentation/devicetree/bindings/net/fsl-fec.txt]
   The fec node supports properties

	phy-reset-gpios =3D <&gpio2 14 0>;
	phy-reset-duration =3D <200> /* milliseconds */;

   Something similar exists in TI's vendor kernel
   (http://git.ti.com/ti-linux-kernel/ti-linux-kernel/commit/17d192b999=
ee904ced223c16cef76111a51c461b)
   with different (and IMHO bader) naming.
   This is the wrong place to specify the gpios; they shouldn't be in t=
he
   mac's node, but in a phy node instead.

So what I actually want is to put the gpio specification in the right
place and let it look as follows:

	mymdiobus {
		[...]
		myfirstphy: ethernet-phy@0 {
			compatible =3D "ethernet-phy-ieee802.3-c22";
			reg =3D <0>;

			reset-gpios =3D <&gpio2 14 0>;
			reset-duration-ms =3D <200>;
		};

		mysecondphy: ethernet-phy@2 {
			compatible =3D "ethernet-phy-ieee802.3-c22";
			reg =3D <2>;

			reset-gpios =3D <&gpio3 10 0>;
			reset-duration-ms =3D <200>;
		};
	};

And with this we could defer probe of &myfirstphy if &gpio2 isn't
available yet.

Does this sound sensible? Does something like that already exist which =
I
missed? Any further ideas/comments?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
