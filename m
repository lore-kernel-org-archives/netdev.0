From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/4] net: mvneta: driver for Marvell Armada 370/XP network
 unit
Date: Tue, 4 Sep 2012 14:36:36 +0000
Message-ID: <201209041436.36430.arnd@arndb.de>
References: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1346764004-16332-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Ike Pan <ike.pan@canonical.com>, Albert Stone <albert.stone@canonical.com>,
 Nadav Haklai <nadavh@marvell.com>, Ian Molton <ian.molton@codethink.co.uk>,
 Lennert Buytenhek <kernel@wantstofly.org>, David Marlin <dmarlin@redhat.com>,
 Rami Rosen <rosenr@marvell.com>, Yehuda Yitschak <yehuday@marvell.com>,
 Jani Monoses <jani.monoses@canonical.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Dan Frazier <dann.frazier@canonical.com>, Eran Ben-Avi <benavi@marvell.com>,
 Li Li <li.li@canonical.com>, Leif Lindholm <leif.lindholm@arm.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Jon Masters <jcm@redhat.com>,
 Ben Dooks <ben-linux@fluff.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Chris Van Hoof <vanhoof@ca
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1346764004-16332-2-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 September 2012, Thomas Petazzoni wrote:
>  .../devicetree/bindings/net/marvell-neta.txt       |   24 +
>  drivers/net/ethernet/marvell/Kconfig               |   11 +
>  drivers/net/ethernet/marvell/Makefile              |    1 +
>  drivers/net/ethernet/marvell/mvneta.c              | 2732 ++++++++++++++++++++
>  drivers/net/ethernet/marvell/mvneta.h              |  496 ++++
>  5 files changed, 3264 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/marvell-neta.txt
>  create mode 100644 drivers/net/ethernet/marvell/mvneta.c
>  create mode 100644 drivers/net/ethernet/marvell/mvneta.h

I usually prefer putting the definitions into the .c file rather
than a separate header if there is only only file including it
anyway.

> diff --git a/Documentation/devicetree/bindings/net/marvell-neta.txt b/Documentation/devicetree/bindings/net/marvell-neta.txt
> new file mode 100644
> index 0000000..a031978
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/marvell-neta.txt
> @@ -0,0 +1,24 @@
> +* Marvell Armada 370 / Armada XP Ethernet Controller (NETA)
> +
> +Required properties:
> +- compatible: should be "marvell,neta".
> +- reg: address and length of the register set for the device.
> +- interrupts: interrupt for the device
> +- phy-mode: String, operation mode of the PHY interface. Supported
> +  values are "sgmii" and "rmii".
> +- phy-addr: Integer, address of the PHY.
> +- device_type: should be "network".
> +- clock-frequency: frequency of the peripheral clock of the SoC.
> +
> +Example:
> +
> +eth@d0070000 {
> +               compatible = "marvell,neta";
> +               reg = <0xd0070000 0x2500>;
> +               interrupts = <8>;
> +               device_type = "network";
> +               clock-frequency = <250000000>;
> +               status = "okay";
> +               phy-mode = "sgmii";
> +               phy-addr = <25>;

I think we normally put the phy into a separate device node on an
mdio bus and then use the of_phy_* functions to connect it to
the ethernet device.

	Arnd
