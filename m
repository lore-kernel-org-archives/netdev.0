From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC V2 0/2] add Qualcomm QCA7000 ethernet driver
Date: Tue,  1 Jul 2014 18:36:47 +0200
Message-ID: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org
To: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, eric.dumazet@gmail.com,
	dave.taht@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:65102 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400AbaGAQhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 12:37:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the Qualcomm QCA7000 Homeplug GreenPHY.
The QCA7000 is serial-to-powerline bridge with two interfaces: UART and SPI.
These patches handles only the last one, with an Ethernet over SPI protocol
driver.

This driver based on the Qualcomm code [1], but contains a lot of changes
since last year:

* devictree support
* DebugFS support
* ethtool support
* better error handling
* performance improvements
* code cleanup
* some bugfixes

For more details look at our git repository [2].

The code has been tested only on Freescale i.MX28 boards, but should work
on other platforms.

Any comments about the code are welcome.

[1] - https://github.com/IoE/qca7000
[2] - https://github.com/I2SE/qca7000/tree/linux-mainline

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
  This patch adds the Device tree bindings for the Ethernet over SPI   
     protocol driver of the Qualcomm QCA7000 HomePlug GreenPHY.
  This patch adds the Ethernet over SPI driver for the Qualcomm QCA7000
        HomePlug GreenPHY.

 .../devicetree/bindings/net/qca-qca7000-spi.txt    |   47 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/qualcomm/Kconfig              |   30 +
 drivers/net/ethernet/qualcomm/Makefile             |    6 +
 drivers/net/ethernet/qualcomm/qca_7k.c             |  149 +++
 drivers/net/ethernet/qualcomm/qca_7k.h             |   72 ++
 drivers/net/ethernet/qualcomm/qca_debug.c          |  311 ++++++
 drivers/net/ethernet/qualcomm/qca_debug.h          |   34 +
 drivers/net/ethernet/qualcomm/qca_framing.c        |  155 +++
 drivers/net/ethernet/qualcomm/qca_framing.h        |  134 +++
 drivers/net/ethernet/qualcomm/qca_spi.c            | 1001 ++++++++++++++++++++
 drivers/net/ethernet/qualcomm/qca_spi.h            |  114 +++
 13 files changed, 2055 insertions(+)
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
1.7.10.4
