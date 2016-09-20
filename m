From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH net-next 0/8] net: qualcomm: add QCA7000 UART driver
Date: Tue, 20 Sep 2016 15:02:16 +0200
Message-ID: <1474376544-20515-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>
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

The patches 1 - 3 are just for clean up and are not related to
the UART support. Patches 4 - 7 prepare the existing QCA7000
code for UART support. The last patch contains the new driver.

In order to test the driver a modified slattach in userspace is also
required. A prepared busybox (includes slattach) can be found here [2].

The code itself has been tested on a Freescale i.MX28 board.

[1] - https://github.com/IoE/qca7000
[2] - https://github.com/lategoodbye/busybox/commits/qca7k_support_1_24

Stefan Wahren (8):
  net: qualcomm: remove unnecessary includes
  net: qca_debug: use net_device_ops instead of direct call
  net: qualcomm: move qcaspi_tx_cmd to qca_spi.c
  net: qualcomm: rename qca_framing.c to qca_common.c
  net: qualcomm: move MTU handling to qca_common
  net: qualcomm: prepare frame decoding for UART driver
  net: qualcomm: make qca_common a separate kernel module
  net: qualcomm: add QCA7000 UART driver

 drivers/net/ethernet/qualcomm/Kconfig       |  20 +-
 drivers/net/ethernet/qualcomm/Makefile      |   7 +-
 drivers/net/ethernet/qualcomm/qca_7k.c      |  28 --
 drivers/net/ethernet/qualcomm/qca_7k.h      |   1 -
 drivers/net/ethernet/qualcomm/qca_common.c  | 178 +++++++++++
 drivers/net/ethernet/qualcomm/qca_common.h  | 147 +++++++++
 drivers/net/ethernet/qualcomm/qca_debug.c   |   5 +-
 drivers/net/ethernet/qualcomm/qca_framing.c | 156 ----------
 drivers/net/ethernet/qualcomm/qca_framing.h | 134 ---------
 drivers/net/ethernet/qualcomm/qca_spi.c     |  41 ++-
 drivers/net/ethernet/qualcomm/qca_spi.h     |   5 +-
 drivers/net/ethernet/qualcomm/qca_uart.c    | 447 ++++++++++++++++++++++++++++
 include/uapi/linux/tty.h                    |   1 +
 13 files changed, 828 insertions(+), 342 deletions(-)
 create mode 100644 drivers/net/ethernet/qualcomm/qca_common.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_common.h
 delete mode 100644 drivers/net/ethernet/qualcomm/qca_framing.c
 delete mode 100644 drivers/net/ethernet/qualcomm/qca_framing.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_uart.c

-- 
2.1.4
