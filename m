From: Jon Mason <jon.mason@broadcom.com>
Subject: [RFC 0/7] net: ethernet: bgmac: Add platform device support
Date: Tue, 28 Jun 2016 15:34:37 -0400
Message-ID: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm sending out this RFC to see if this is the direction the maintainers
would like to go to add support for other, non-bcma iProc SoC's to the
bgmac driver.  Specifically, we are interested in adding support for the
NSP, Cygnus, and NS2 families (with more possible down the road).

To support non-bcma enabled SoCs, we need to add the standard device
tree "platform device" support.  Unfortunately, this driver is very
tighly coupled with the bcma bus and much unwinding is needed.  I tried
to break this up into a number of patches to make it more obvious what
was being done to add platform device support.  I was able to verify
that the bcma code still works using a 53012K board (NS SoC), and that
the platform code works using a 58625K board (NSP SoC).

It is worth noting that the phy logic present in the driver needs to be
moved to drivers/phy.  However, I was not able to fully decouple that
code from the bgmac driver.  I was able to move it into a separate C
file, with only 2 function calls needed to create and destroy the mii
bus.  Someone with more knowledge of this and HW to test it needs to do
it properly.  This would natually dovetail into creating an interface
which the NSP bgmac can use for the external MDIO Phy to properly
connect (instead of using the fixed phy).

Thanks,
Jon


Jon Mason (7):
  net: ethernet: bgmac: change bgmac_* prints to dev_* prints
  net: ethernet: bgmac: add dma_dev pointer
  net: ethernet: bgmac: move BCMA MDIO Phy code into a separate file
  net: ethernet: bgmac: convert to feature flags
  net: ethernet: bgmac: Add platform device support
  dt-bindings: net: bgmac: add bindings documentation for bgmac
  ARM: dts: NSP: Add bgmac entries

 .../devicetree/bindings/net/brcm,bgmac-enet.txt    |  21 +
 arch/arm/boot/dts/bcm-nsp.dtsi                     |  16 +
 arch/arm/boot/dts/bcm958625k.dts                   |   8 +
 drivers/net/ethernet/broadcom/Kconfig              |  23 +-
 drivers/net/ethernet/broadcom/Makefile             |   2 +
 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c    | 264 +++++++++
 drivers/net/ethernet/broadcom/bgmac-bcma.c         | 315 ++++++++++
 drivers/net/ethernet/broadcom/bgmac-platform.c     | 208 +++++++
 drivers/net/ethernet/broadcom/bgmac.c              | 658 +++++----------------
 drivers/net/ethernet/broadcom/bgmac.h              | 112 +++-
 10 files changed, 1111 insertions(+), 516 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
 create mode 100644 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
 create mode 100644 drivers/net/ethernet/broadcom/bgmac-bcma.c
 create mode 100644 drivers/net/ethernet/broadcom/bgmac-platform.c

-- 
1.9.1
