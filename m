From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 0/5] net-next: ethernet: add sun8i-emac driver
Date: Wed, 20 Jul 2016 10:03:15 +0200
Message-ID: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBXHAXS6AKGQENAGQWNQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hello

This patch series add the driver for sun8i-emac which handle the Ethernet MAC
present on Allwinner H3/A83T/A64 SoCs.

It supports 10/100/1000 Mbit/s speed with half/full duplex.
It can use an internal PHY (MII 10/100) or an external PHY
via RGMII/RMII.

This patch series enable the driver only for the H3 SoC since A83T and A64
doesn't have the necessary clocks present in mainline.

This patch series enable the driver only for the OrangePiPC board since other
board with H3 use external PHY which need optional regulators that will be
supported later.

The driver have been tested on the following boards:
- H3 Orange PI PC, Orange PI Plus, BananaPI-M2+
- A64 Pine64
- A83T BananaPI-M3

I would like to thanks Chen-Yu Tsai for his help on developing this driver.

Regards

Changes since v1
- Implement NAPI
- Sorted and reworded all define
- Reworked ethtools stats strings
- Removed all unneeded __packked and __aligned
- Added tuning of RX/TX ring size via ethtool
- Corrected use of sk/skb naming
- Added some wmb when needed
- Moved irq claim/free to emac_open/close
- Lots of code refactoring

LABBE Corentin (5):
  ethernet: add sun8i-emac driver
  MAINTAINERS: Add myself as maintainers of sun8i-emac
  ARM: sun8i: dt: Add DT bindings documentation for Allwinner sun8i-emac
  ARM: dts: sun8i-h3: add sun8i-emac ethernet driver
  ARM: dts: sun8i: Enable sun8i-emac on the Orange PI PC

 .../bindings/net/allwinner,sun8i-emac.txt          |   65 +
 MAINTAINERS                                        |    6 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |   11 +
 arch/arm/boot/dts/sun8i-h3.dtsi                    |   14 +
 drivers/net/ethernet/allwinner/Kconfig             |   13 +
 drivers/net/ethernet/allwinner/Makefile            |    1 +
 drivers/net/ethernet/allwinner/sun8i-emac.c        | 2127 ++++++++++++++++++++
 7 files changed, 2237 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
 create mode 100644 drivers/net/ethernet/allwinner/sun8i-emac.c

-- 
2.7.3
