From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC v4 00/10] net: qualcomm: add QCA7000 UART driver
Date: Mon, 27 Mar 2017 15:37:18 +0200
Message-ID: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Qualcomm QCA7000 HomePlug GreenPHY supports two interfaces:
UART and SPI. This patch series adds the missing support for UART.

This driver based on the Qualcomm code [1], but contains some changes:
* use random MAC address per default
* use net_device_stats from device
* share frame decoding between SPI and UART driver
* improve error handling
* reimplement tty_wakeup with work queue (based on slcan)
* use new serial device bus instead of ldisc

The patches 1 - 3 are just for clean up and are not related to
the UART support. Patches 4 - 7 prepare the existing QCA7000
code for UART support. Patch 8 contains the new driver. The last
two patches are suggested improvements for serial device bus.

The code itself has been tested on a Freescale i.MX28 board and
a Raspberry Pi Zero.

Changes in v4:
  * rebase to current linux-next
  * use parameter -M for git format-patch
  * change order of local variables where possible
  * implement basic serdev support (without hardware flow control)

Changes in v3:
  * rebase to current net-next

Changes in v2:
  * fix build issue by using netif_trans_update() and dev_trans_start()

[1] - https://github.com/IoE/qca7000

Stefan Wahren (10):
  net: qualcomm: remove unnecessary includes
  net: qca_debug: use net_device_ops instead of direct call
  net: qualcomm: move qcaspi_tx_cmd to qca_spi.c
  net: qualcomm: rename qca_framing.c to qca_common.c
  net: qualcomm: prepare frame decoding for UART driver
  net: qualcomm: make qca_common a separate kernel module
  dt-bindings: net: add binding for QCA7000 UART
  net: qualcomm: add QCA7000 UART driver
  tty: serdev-ttyport: return actual baudrate from ttyport_set_baudrate
  tty: serdev: add functions to retrieve common UART settings

 .../devicetree/bindings/net/qca-qca7000-uart.txt   |  31 ++
 drivers/net/ethernet/qualcomm/Kconfig              |  18 +-
 drivers/net/ethernet/qualcomm/Makefile             |   7 +-
 drivers/net/ethernet/qualcomm/qca_7k.c             |  28 --
 drivers/net/ethernet/qualcomm/qca_7k.h             |   1 -
 .../qualcomm/{qca_framing.c => qca_common.c}       |  24 +-
 .../qualcomm/{qca_framing.h => qca_common.h}       |  14 +-
 drivers/net/ethernet/qualcomm/qca_debug.c          |   5 +-
 drivers/net/ethernet/qualcomm/qca_spi.c            |  28 +-
 drivers/net/ethernet/qualcomm/qca_spi.h            |   5 +-
 drivers/net/ethernet/qualcomm/qca_uart.c           | 419 +++++++++++++++++++++
 drivers/tty/serdev/core.c                          |  33 ++
 drivers/tty/serdev/serdev-ttyport.c                |  49 ++-
 include/linux/serdev.h                             |  22 ++
 14 files changed, 634 insertions(+), 50 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-uart.txt
 rename drivers/net/ethernet/qualcomm/{qca_framing.c => qca_common.c} (86%)
 rename drivers/net/ethernet/qualcomm/{qca_framing.h => qca_common.h} (90%)
 create mode 100644 drivers/net/ethernet/qualcomm/qca_uart.c

-- 
2.1.4
