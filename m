From: Peter Griffin <peter.griffin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 0/7] Fix sti drivers whcih mix reg address spaces
Date: Wed,  7 Jan 2015 15:04:05 +0000
Message-ID: <1420643052-4506-1-git-send-email-peter.griffin@linaro.org>
Cc: peter.griffin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	srinivas.kandagatla-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, maxime.coquelin-qxv4g6HH51o@public.gmane.org,
	patrice.chotard-qxv4g6HH51o@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org, kishon-l0cyMroinI0@public.gmane.org,
	arnd-r2nGTMty4D4@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi folks,

A V2 of this old series incorporating Arnd and Lees Feedback form v1.

Following on from Arnds comments about the picophy driver here
https://lkml.org/lkml/2014/11/13/161, this series fixes the
remaining upstreamed drivers for STI, which are mixing address spaces
in the reg property. We do this in a way similar to the keystone
and bcm7445 platforms, by having sysconfig phandle/ offset pair 
(where only one register is required). Or phandle / integer array
where multiple offsets in the same bank are needed).

This series breaks DT compatability! But the platform support
is WIP and only being used by the few developers who are upstreaming
support for it. I've made each change to the driver / dt doc / dt
file as a single atomic commit so the kernel will remain bisectable. 

This series then also enables the picophy driver, and adds back in
the ehci/ohci dt nodes for stih410 which make use of the picophy.

regards,

Peter.

Changes since v1:
- Add missing space after */ (Lee)
- Change comment to "indexed from" rather than "not indexed from" (Lee)
- Change naming to phy1, phy2 rather than phy@1 phy@2 if there is no reg property (Arnd / Grant)
- Rebased on v3.19-rc3 (me)
- Checkpatch "no space before tabs" warning in stih41*.dtsi (me)

Peter Griffin (7):
  phy: phy-stih407-usb: Pass sysconfig register offsets via syscfg
    property.
  phy: miphy365x: Pass sysconfig register offsets via syscfg dt
    property.
  ARM: STi: DT: STiH407: Add usb2 picophy dt nodes
  ARM: STi: DT: STiH410: Add usb2 picophy dt nodes
  ARM: STi: DT: STiH410: Add DT nodes for the ehci and ohci usb
    controllers.
  ARM: multi_v7_defconfig: Enable stih407 usb picophy
  stmmac: dwmac-sti: Pass sysconfig register offset via syscon dt
    property.

 .../devicetree/bindings/net/sti-dwmac.txt          | 14 ++---
 .../devicetree/bindings/phy/phy-miphy365x.txt      | 15 ++---
 .../devicetree/bindings/phy/phy-stih407-usb.txt    | 10 +---
 arch/arm/boot/dts/stih407-family.dtsi              |  9 +++
 arch/arm/boot/dts/stih410.dtsi                     | 70 ++++++++++++++++++++++
 arch/arm/boot/dts/stih415.dtsi                     | 12 ++--
 arch/arm/boot/dts/stih416.dtsi                     | 22 +++----
 arch/arm/configs/multi_v7_defconfig                |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 13 ++--
 drivers/phy/phy-miphy365x.c                        | 29 ++++-----
 drivers/phy/phy-stih407-usb.c                      | 25 ++++----
 11 files changed, 143 insertions(+), 77 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
