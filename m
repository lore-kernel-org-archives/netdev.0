From: Sergei Ianovich <ynvich@gmail.com>
Subject: Re: [PATCH v3] net: ethernet: davicom: fix devicetree irq resource
Date: Mon, 22 Feb 2016 03:54:21 +0300
Message-ID: <1456102461.2386.6.camel@gmail.com>
References: <1456001126-13129-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456001126-13129-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-02-20 at 21:45 +0100, Robert Jarzmik wrote:
> The dm9000 driver doesn't work in at least one device-tree
> configuration, spitting an error message on irq resource :
> [=C2=A0=C2=A0=C2=A0=C2=A01.062495] dm9000 8000000.ethernet: insuffici=
ent resources
> [=C2=A0=C2=A0=C2=A0=C2=A01.068439] dm9000 8000000.ethernet: not found=
 (-2).
> [=C2=A0=C2=A0=C2=A0=C2=A01.073451] dm9000: probe of 8000000.ethernet =
failed with error -2
>=20
> The reason behind is that the interrupt might be provided by a gpio
> controller, not probed when dm9000 is probed, and needing the probe
> deferral mechanism to apply.
>=20
> Currently, the interrupt is directly taken from resources. This patch
> changes this to use the more generic platform_get_irq(), which
> handles
> the deferral.
>=20
> Moreover, since commit Fixes: 7085a7401ba5 ("drivers: platform: parse
> IRQ flags from resources"), the interrupt trigger flags are honored
> in
> platform_get_irq(), so remove the needless code in dm9000.
>=20
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Acked-by: Marcel Ziswiler <marcel@ziswiler.com>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20

Tested-by: Sergei Ianovich <ynvich@gmail.com>

I've hit the original bug too. This patch fixes the *regression*. It
may be worth adding a note about this.

--=20
Sergei Ianovich <ynvich@gmail.com>
