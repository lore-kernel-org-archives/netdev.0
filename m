From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v5 0/4] net: Add APM X-Gene SoC Ethernet driver support
Date: Mon,  2 Jun 2014 12:39:10 -0700
Message-ID: <1401737954-26152-1-git-send-email-isubramanian@apm.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og109.obsmtp.com ([64.18.0.188]:40752 "HELO
	exprod5og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751996AbaFBTi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 15:38:58 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so4495235pbb.8
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 12:38:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding APM X-Gene SoC Ethernet driver.

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

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
*** BLURB HERE ***

Iyappan Subramanian (4):
  MAINTAINERS: Add entry for APM X-Gene SoC ethernet driver
  Documentation: dts: Add bindings for APM X-Gene SoC ethernet driver
  dts: Add bindings for APM X-Gene SoC ethernet driver
  drivers: net: Add APM X-Gene SoC ethernet driver support.

 .../devicetree/bindings/net/apm-xgene-enet.txt     |   72 ++
 MAINTAINERS                                        |    8 +
 arch/arm64/boot/dts/apm-mustang.dts                |    4 +
 arch/arm64/boot/dts/apm-storm.dtsi                 |   30 +-
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/apm/Kconfig                   |    1 +
 drivers/net/ethernet/apm/Makefile                  |    5 +
 drivers/net/ethernet/apm/xgene/Kconfig             |    9 +
 drivers/net/ethernet/apm/xgene/Makefile            |    6 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |  901 ++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  395 ++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |  959 ++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  131 +++
 14 files changed, 2520 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt
 create mode 100644 drivers/net/ethernet/apm/Kconfig
 create mode 100644 drivers/net/ethernet/apm/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h

-- 
1.7.9.5
