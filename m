From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.13] NFC update
Date: Fri, 30 Jun 2017 11:37:20 +0200
Message-ID: <20170630093720.GO21214@zurbaran.ger.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Linux Wireless <linux-wireless@vger.kernel.org>,
        Linux NFC <linux-nfc@lists.01.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43583 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751421AbdF3JhY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 05:37:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the NFC pull request for 4.13. We have:

- A conversion to unified device and GPIO APIs for the
  fdp, pn544, and st{21,-nci} drivers.
- A fix for NFC device IDs allocation.
- A fix for the nfcmrvl driver firmware download mechanism.
- A trf7970a DT and GPIO cleanup and clock setting fix.
- A few fixes for potential overflows in the digital and LLCP code.

The following changes since commit 06d4d450db770a70b29fa0244d50390c85e7e3c7:

  net: dsa: Fix legacy probing (2017-06-17 22:59:45 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.13-1

for you to fetch changes up to bd751808f9ff5e1822c627f6c4283009e66b2e53:

  NFC: trf7970a: Correct register settings for 27MHz clock (2017-06-28 09:16:54 +0200)

----------------------------------------------------------------
Andy Shevchenko (13):
      NFC: pn544: Switch to devm_acpi_dev_add_driver_gpios()
      NFC: st21nfca: Add GPIO ACPI mapping table
      NFC: st21nfca: Get rid of code duplication in ->probe()
      NFC: fdp: Convert I2C driver to ->probe_new()
      NFC: fdp: Convert to use devres API
      NFC: fdp: Add GPIO ACPI mapping table
      NFC: st-nci: Get rid of platform data
      NFC: st-nci: Get rid of "interesting" use of interrupt polarity
      NFC: st-nci: Covert to use GPIO descriptor
      NFC: st-nci: Use unified device properties API meaningfully
      NFC: st-nci: Add GPIO ACPI mapping table
      NFC: st-nci: Get rid of code duplication in ->probe()
      MAINTAINERS: Remove non-existing NFC platform data files

Colin Ian King (1):
      NFC: trf7970a: fix check of clock frequencies, use && instead of ||

Geoff Lansberry (1):
      NFC: trf7970a: Correct register settings for 27MHz clock

Gustavo A. R. Silva (2):
      nfc: nci: remove unnecessary null check
      NFC: add NULL checks to avoid potential NULL pointer dereference

Johan Hovold (8):
      NFC: fix broken device allocation
      NFC: nfcmrvl_uart: add missing tty-device sanity check
      NFC: nfcmrvl: do not use device-managed resources
      NFC: nfcmrvl: use nfc-device for firmware download
      NFC: nfcmrvl: fix firmware-management initialisation
      NFC: nfcmrvl_uart: fix device-node leak during probe
      NFC: nfcmrvl_usb: use interface as phy device
      NFC: nfcmrvl: allow gpio 0 for reset signalling

Mark Greer (12):
      MAINTAINERS: NFC: trf7970a: Add Mark Greer as maintainer
      NFC: trf7970a: Don't de-assert EN2 unless it was asserted
      NFC: trf7970a: Fix inaccurate comment in trf7970a_probe()
      NFC: trf7970a: Only check 'en2-rf-quirk' if EN2 is specified
      NFC: trf7970a: Remove useless comment
      NFC: trf7970a: Remove support for 'vin-voltage-override' DT property
      NFC: trf7970a: Enable pins are active high not active low
      NFC: trf7970a: Convert to descriptor based GPIO interface
      NFC: trf7970a: Clean up coding style issues
      NFC: digital: NFC-A SEL_RES must be one byte
      NFC: digital: NFC-DEP Target WT(nfcdep,max) is now 14
      Revert "NFC: trf7970a: Handle extra byte in response to Type 5 RMB commands"

Markus Elfring (2):
      NFC: digital: Improve a size determination in four functions
      NFC: digital: Delete an error message for memory allocation failure

Mateusz Jurczyk (3):
      nfc: Fix the sockaddr length sanitization in llcp_sock_connect
      nfc: Ensure presence of required attributes in the activate_target handler
      NFC: Add sockaddr length checks before accessing sa_family in bind handlers

 .../devicetree/bindings/net/nfc/trf7970a.txt       |  10 +-
 MAINTAINERS                                        |  11 +-
 drivers/nfc/Kconfig                                |   2 +-
 drivers/nfc/fdp/fdp.c                              |  15 +-
 drivers/nfc/fdp/i2c.c                              |  38 +-
 drivers/nfc/nfcmrvl/fw_dnld.c                      |   7 +-
 drivers/nfc/nfcmrvl/main.c                         |  40 ++-
 drivers/nfc/nfcmrvl/uart.c                         |  11 +-
 drivers/nfc/nfcmrvl/usb.c                          |   4 +-
 drivers/nfc/nfcsim.c                               |   6 +-
 drivers/nfc/pn544/i2c.c                            |   3 +-
 drivers/nfc/st-nci/i2c.c                           | 164 ++-------
 drivers/nfc/st-nci/spi.c                           | 162 ++-------
 drivers/nfc/st21nfca/i2c.c                         |  62 +---
 drivers/nfc/trf7970a.c                             | 391 ++++++++++-----------
 include/linux/platform_data/nfcmrvl.h              |   2 +-
 include/linux/platform_data/st-nci.h               |  31 --
 net/nfc/core.c                                     |  31 +-
 net/nfc/digital_core.c                             |  12 +-
 net/nfc/digital_dep.c                              |   2 +-
 net/nfc/digital_technology.c                       |   3 +-
 net/nfc/llcp_sock.c                                |   9 +-
 net/nfc/nci/core.c                                 |  12 +-
 net/nfc/netlink.c                                  |   4 +-
 24 files changed, 363 insertions(+), 669 deletions(-)
 delete mode 100644 include/linux/platform_data/st-nci.h
