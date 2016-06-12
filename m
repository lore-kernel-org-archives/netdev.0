From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/5] net-next: ethernet: add sun8i-emac driver
Date: Sun, 12 Jun 2016 13:22:23 +0200
Message-ID: <c8037d93-1d12-fdfb-a88b-e88ff0f72d52@redhat.com>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
Reply-To: hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------63AEC2D0A22D8FDA5B3AF78A"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
        galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-sunxi+bncBDRZXY4CYYORB7EL6W5AKGQEPDW4AUA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1464947790-22991-1-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------63AEC2D0A22D8FDA5B3AF78A
Content-Type: text/plain; charset=UTF-8; format=flowed

Hi,

On 03-06-16 11:56, LABBE Corentin wrote:
> Hello
>
> This patch series add the driver for sun8i-emac which handle the Ethernet MAC
> present on Allwinner H3/A83T/A64 SoCs.
>
> It supports 10/100/1000 Mbit/s speed with half/full duplex.
> It can use an internal PHY (MII 10/100) or an external PHY
> via RGMII/RMII.
>
> This patch series enable the driver only for the H3 SoC since A83T and A64
> doesn't have the necessary clocks present in mainline.
>
> This patch series enable the driver only for the OrangePiPC board since other
> board with H3 use external PHY which need optional regulators that will be
> supported later.
>
> The driver have been tested on the following boards:
> - H3 Orange PI PC, Orange PI Plus, BananaPI-M2+
> - A64 Pine64
> - A83T BananaPI-M3
>
> I would like to thanks Chen-Yu Tsai for his help on developing this driver.

Awesome! Thanks for your work on this.

I've tested this on a orangepi-one. You can add my:

Tested-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

For the next version of this series.

Attached is a dts patch for adding support
for the emac one that one (to be applied on top of this patch-set).

I've a Orange PI Plus and a Orange PI 2 as well, both of which use an external
phy, I would love to test on those as well, do you've a tree with adds the
necessary regulator bits and an example of how this would like in dts
somewhere ?

One remark about:
[PATCH 5/5] ARM: dts: sun8i: Enable sun8i-emac on the Orange PI PC

We always keep the nodes in board.dts files sorted alphebetically,
so the emac node should be after the ehci node rather then at the end.

Regards,

Hans

>
> Regards
>
> LABBE Corentin (5):
>   ethernet: add sun8i-emac driver
>   MAINTAINERS: Add myself as maintainers of sun8i-emac
>   ARM: sun8i: dt: Add DT bindings documentation for Allwinner sun8i-emac
>   ARM: dts: sun8i-h3: add sun8i-emac ethernet driver
>   ARM: dts: sun8i: Enable sun8i-emac on the Orange PI PC
>
>  .../bindings/net/allwinner,sun8i-emac.txt          |   64 +
>  MAINTAINERS                                        |    6 +
>  arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |   11 +
>  arch/arm/boot/dts/sun8i-h3.dtsi                    |   14 +
>  drivers/net/ethernet/allwinner/Kconfig             |   13 +
>  drivers/net/ethernet/allwinner/Makefile            |    1 +
>  drivers/net/ethernet/allwinner/sun8i-emac.c        | 1943 ++++++++++++++++++++
>  7 files changed, 2052 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
>  create mode 100644 drivers/net/ethernet/allwinner/sun8i-emac.c
>

-- 
You received this message because you are subscribed to the Google Groups "linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.

--------------63AEC2D0A22D8FDA5B3AF78A
Content-Type: text/x-patch;
 name="0001-ARM-dts-sun8i-Enable-sun8i-emac-on-the-Orange-PI-One.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ARM-dts-sun8i-Enable-sun8i-emac-on-the-Orange-PI-One.pa";
 filename*1="tch"

>From 25ea802c4c2962dc50c34bd02faa9a5f3acd2e34 Mon Sep 17 00:00:00 2001
From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Sun, 12 Jun 2016 13:20:05 +0200
Subject: [PATCH v3] ARM: dts: sun8i: Enable sun8i-emac on the Orange PI One

The sun8i-emac hardware is present on the Orange PI One.
It uses the internal PHY.

This patch create the needed emac and phy nodes.

Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts
index 0adf932..8df5c74 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts
@@ -94,6 +94,17 @@
 	status = "okay";
 };
 
+&emac {
+	phy = <&phy1>;
+	phy-mode = "mii";
+	allwinner,use-internal-phy;
+	allwinner,leds-active-low;
+	status = "okay";
+	phy1: ethernet-phy@1 {
+		reg = <1>;
+	};
+};
+
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>, <&mmc0_cd_pin>;
--------------63AEC2D0A22D8FDA5B3AF78A--
