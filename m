From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH V3 0/2] add Qualcomm QCA7000 ethernet driver
Date: Fri, 26 Sep 2014 22:21:19 +0000
Message-ID: <1411770081-20995-1-git-send-email-stefan.wahren@i2se.com>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:50580 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755683AbaIZWVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 18:21:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the Qualcomm QCA7000 Homeplug GreenPHY.
The QCA7000 is serial-to-powerline bridge with two interfaces: UART and SPI.
These patches handles only the last one, with an Ethernet over SPI protocol
driver.

This driver based on the Qualcomm code [1], but contains a lot of changes
since last year:

* devicetree support
* DebugFS support
* ethtool support
* better error handling
* performance improvements
* code cleanup
* some bugfixes

The code has been tested only on Freescale i.MX28 boards, but should work
on other platforms.

[1] - https://github.com/IoE/qca7000

Changes in V3:
- Use ether_addr_copy instead of memcpy
- Remove qcaspi_set_mac_address
- Improve DT parsing
- replace OF_GPIO dependancy with OF
- fix compile error caused by SET_ETHTOOL_OPS
- fix possible endless loop when spi read fails
- fix DT documentation
- fix coding style
- fix sparse warnings

Changes in V2:
- replace in DT the SPI intr GPIO with pure interrupt
- make legacy mode a boolean DT property and remove it as module parameter
- make burst length a module parameter instead of DT property
- make pluggable a module parameter instead of DT property
- improve DT documentation
- replace debugFS register dump with ethtool function
- replace debugFS stats with ethtool function
- implement function to get ring parameter via ethtool
- implement function to set TX ring count via ethtool
- fix TX ring state in debugFS
- optimize tx ring flush
- add byte limit for TX ring to avoid bufferbloat
- fix TX queue full and write buffer miss counter
- fix SPI clk speed module parameter
- fix possible packet loss
- fix possible race during transmit


Stefan Wahren (2):
  Documentation: add Device tree bindings for QCA7000
  net: qualcomm: new Ethernet over SPI driver for QCA7000

 .../devicetree/bindings/net/qca-qca7000-spi.txt    |   47 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/qualcomm/Kconfig              |   30 +
 drivers/net/ethernet/qualcomm/Makefile             |    6 +
 drivers/net/ethernet/qualcomm/qca_7k.c             |  149 +++
 drivers/net/ethernet/qualcomm/qca_7k.h             |   72 ++
 drivers/net/ethernet/qualcomm/qca_debug.c          |  311 ++++++
 drivers/net/ethernet/qualcomm/qca_debug.h          |   34 +
 drivers/net/ethernet/qualcomm/qca_framing.c        |  156 +++
 drivers/net/ethernet/qualcomm/qca_framing.h        |  134 +++
 drivers/net/ethernet/qualcomm/qca_spi.c            |  993 ++++++++++++++++++++
 drivers/net/ethernet/qualcomm/qca_spi.h            |  114 +++
 13 files changed, 2048 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
 create mode 100644 drivers/net/ethernet/qualcomm/Kconfig
 create mode 100644 drivers/net/ethernet/qualcomm/Makefile
 create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.h

-- 
1.7.9.5
