From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 0/7] NFC: fix device allocation and nfcmrvl crashes
Date: Wed, 29 Mar 2017 18:21:05 +0200
Message-ID: <20170329162112.18121-1-johan@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This started out with the observation that the nfcmrvl_uart driver
unconditionally dereferenced the tty class device despite the fact that
not every tty has an associated struct device (Unix98 ptys). Some
further changes were needed in the common nfcmrvl code to fully address
this, some of which also incidentally fixed a few related bugs (e.g.
resource leaks in error paths).

While fixing this I stumbled over a regression in NFC core that lead to
broken registration error paths and misnamed workqueues.

Note that this has only been tested by configuring the n_hci line
discipline for different ttys without any actual NFC hardware connected.

Johan


Johan Hovold (7):
  NFC: fix broken device allocation
  NFC: nfcmrvl_uart: add missing tty-device sanity check
  NFC: nfcmrvl: do not use device-managed resources
  NFC: nfcmrvl: use nfc-device for firmware download
  NFC: nfcmrvl: fix firmware-management initialisation
  NFC: nfcmrvl_uart: fix device-node leak during probe
  NFC: nfcmrvl_usb: use interface as phy device

 drivers/nfc/nfcmrvl/fw_dnld.c |  7 +++++--
 drivers/nfc/nfcmrvl/main.c    | 25 +++++++++++++------------
 drivers/nfc/nfcmrvl/uart.c    | 11 +++++++----
 drivers/nfc/nfcmrvl/usb.c     |  4 +---
 net/nfc/core.c                | 31 ++++++++++++++++++-------------
 net/nfc/nci/core.c            |  3 +--
 6 files changed, 45 insertions(+), 36 deletions(-)

-- 
2.12.2
