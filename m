From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v6 0/4] net: Add APM X-Gene SoC Ethernet driver support
Date: Mon, 16 Jun 2014 17:18:42 -0700
Message-ID: <1402964326-11147-1-git-send-email-isubramanian@apm.com>
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding APM X-Gene SoC Ethernet driver.

v6: Address comments from v5 review
* added basic ethtool support
* added ndo_get_stats64 call back
* deleted priting Rx error messages
* renamed set_bits to xgene_set_bits to fix kbuild error (make ARCH=powerpc)

v5: Address comments from v4 review
* Documentation: Added phy-handle, reg-names and changed mdio part
* dtb: Added reg-names supplemental property
* changed platform_get_resource to platform_get_resource_byname
* added separate tx/rx set_desc/get_desc functions to do raw_write/raw_read
* removed set_desc/get_desc table lookup logic
* added error handling logic based on per packet descriptor bits
* added software managed Rx packet and error counters
* added busy wait for register read/writes
* changed mdio_bus->id to avoid conflict
* fixed mdio_bus leak in case of mdio_config error
* changed phy reg hard coded value to MII_BMSR
* changed phy addr hard coded value to phy_device->addr
* added paranthesis around macro arguments
* converted helper macros to inline functions
* changed use of goto's only to common work such as cleanup

v4: Address comments from v3 review
* MAINTAINERS: changed status to supported
* Kconfig: made default to no
* changed to bool data type wherever applicable
* cleaned up single bit set and masking code
* removed statistics counters masking
* removed unnecessary OOM message printing
* fixed dma_map_single and dma_unmap_single size parameter
* changed set bits macro body using new set_bits function

v3: Address comments from v2 review
* cleaned up set_desc and get_desc functions
* added dtb mdio node and phy-handle subnode
* renamed dtb phy-mode to phy-connection-type
* added of_phy_connect call to connec to PHY
* added empty line after last local variable declaration
* removed type casting when not required
* removed inline keyword from source files
* removed CONFIG_CPU_BIG_ENDIAN ifdef

v2
* Completely redesigned ethernet driver
* Added support to work with big endian kernel
* Renamed dtb phyid entry to phy_addr
* Changed dtb local-mac-address entry to byte string format
* Renamed dtb eth8clk entry to menetclk

v1
* Initial version

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
---

Iyappan Subramanian (4):
  MAINTAINERS: Add entry for APM X-Gene SoC ethernet driver
  Documentation: dts: Add bindings for APM X-Gene SoC ethernet driver
  dts: Add bindings for APM X-Gene SoC ethernet driver
  drivers: net: Add APM X-Gene SoC ethernet driver support.

 .../devicetree/bindings/net/apm-xgene-enet.txt     |  72 ++
 MAINTAINERS                                        |   8 +
 arch/arm64/boot/dts/apm-mustang.dts                |   4 +
 arch/arm64/boot/dts/apm-storm.dtsi                 |  30 +-
 drivers/net/ethernet/Kconfig                       |   1 +
 drivers/net/ethernet/Makefile                      |   1 +
 drivers/net/ethernet/apm/Kconfig                   |   1 +
 drivers/net/ethernet/apm/Makefile                  |   5 +
 drivers/net/ethernet/apm/xgene/Kconfig             |   9 +
 drivers/net/ethernet/apm/xgene/Makefile            |   6 +
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 125 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 848 +++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     | 394 +++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 937 +++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   | 109 +++
 15 files changed, 2547 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt
 create mode 100644 drivers/net/ethernet/apm/Kconfig
 create mode 100644 drivers/net/ethernet/apm/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
