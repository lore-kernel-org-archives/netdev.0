From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [GIT] [4.12] NFC update
Date: Thu, 20 Apr 2017 23:37:07 +0200
Message-ID: <20170420213707.GA25763@zurbaran.ger.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux NFC <linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

This is the NFC pull request for 4.12. We have:

- Improvements for the pn533 command queue handling and device
  registration order.
- Removal of platform data for the pn544 and st21nfca drivers.
- Additional device tree options to support more trf7970a hardware options.
- Support for Sony's RC-S380P through the port100 driver.
- Removal of the obsolte nfcwilink driver.
- Headers inclusion cleanups (miscdevice.h, unaligned.h) for many drivers.

The following changes since commit eefe06e8ceea88f8397a8df0880ab5ca28dcada6:

  Merge branch 'bpf-prog-testing-framework' (2017-04-01 12:45:58 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.12-1

for you to fetch changes up to 4ea206395d3aede32bab94a75ec573530486fa44:

  nfc: fix get_unaligned_...() misuses (2017-04-17 00:42:22 +0200)

----------------------------------------------------------------
NFC 4.12 pull request

This is the NFC pull request for 4.12. We have:

- Improvements for the pn533 command queue handling and device
  registration order.
- Removal of platform data for the pn544 and st21nfca drivers.
- Additional device tree options to support more trf7970a hardware options.
- Support for Sony's RC-S380P through the port100 driver.
- Removal of the obsolte nfcwilink driver.
- Headers inclusion cleanups (miscdevice.h, unaligned.h) for many drivers.

----------------------------------------------------------------
Al Viro (1):
      nfc: fix get_unaligned_...() misuses

Andrey Rusalin (3):
      NFC: pn533: change order of free_irq and dev unregistration
      NFC: pn533: improve cmd queue handling
      NFC: pn533: change order operations in dev registation

Andy Shevchenko (12):
      NFC: pn544: Get rid of platform data
      NFC: pn544: Convert to use GPIO descriptor
      NFC: pn544: Convert to use devm_request_threaded_irq()
      NFC: pn544: Add GPIO ACPI mapping table
      NFC: pn544: Get rid of code duplication in ->probe()
      NFC: st21nfca: Fix obvious typo when check error code
      NFC: st21nfca: Get rid of platform data
      NFC: st21nfca: Get rid of "interesting" use of interrupt polarity
      NFC: st21nfca: Covert to use GPIO descriptor
      NFC: st21nfca: Use unified device property API meaningfully
      NFC: netlink: Use error code from nfc_activate_target()
      NFC: Add nfc_dbg() macro

Christophe JAILLET (1):
      NFC: st21nfca: Fix potential memory leak

Corentin Labbe (3):
      nfc: nxp-nci: Remove unneeded linux/miscdevice.h include
      nfc: pn544: Remove unneeded linux/miscdevice.h include
      nfc: st21nfca: Remove unneeded linux/miscdevice.h include

Dan Carpenter (1):
      NFC: nfcmrvl: double free on error path

Geliang Tang (1):
      NFC: nfcmrvl: drop duplicate header gpio.h

Geoff Lansberry (2):
      NFC: trf7970a: add device tree option for 27MHz clock
      NFC: trf7970a: Add device tree option of 1.8 Volt IO voltage

Guan Ben (1):
      NFC: Make EN2 pin optional in the TRF7970A driver

Guenter Roeck (1):
      NFC: nxp-nci: Include unaligned.h instead of access_ok.h

Michał Mirosław (1):
      NFC: pn533: use constant off-stack buffer for sending acks

Nicholas Mc Guire (1):
      nfc: nxp-nci: use msleep for long delays

OGAWA Hirofumi (4):
      nfc: Add support RC-S380P to port100
      nfc: Send same info for both of NFC_CMD_GET_DEVICE and NFC_EVENT_DEVICE_ADDED
      nfc: Fix RC-S380* needs zero-length packet
      nfc: Fix hangup of RC-S380* in port100_send_ack()

Rob Herring (1):
      NFC: remove TI nfcwilink driver

Samuel Ortiz (1):
      MAINTAINERS: Remove Lauro and Aloisio from the NFC maintainers list

Sudip Mukherjee (1):
      nfc: fdp: fix NULL pointer dereference

Tobias Klauser (1):
      NFC: nfcmrvl: Include unaligned.h instead of access_ok.h

 .../devicetree/bindings/net/nfc/trf7970a.txt       |   8 +-
 MAINTAINERS                                        |   2 -
 drivers/nfc/Kconfig                                |  11 -
 drivers/nfc/Makefile                               |   1 -
 drivers/nfc/fdp/i2c.c                              |   6 +-
 drivers/nfc/nfcmrvl/fw_dnld.c                      |   7 +-
 drivers/nfc/nfcmrvl/spi.c                          |   6 +-
 drivers/nfc/nfcwilink.c                            | 578 ---------------------
 drivers/nfc/nxp-nci/firmware.c                     |   2 +-
 drivers/nfc/nxp-nci/i2c.c                          |   7 +-
 drivers/nfc/pn533/i2c.c                            |  34 +-
 drivers/nfc/pn533/pn533.c                          |  82 +--
 drivers/nfc/pn533/pn533.h                          |   1 +
 drivers/nfc/pn533/usb.c                            |   8 +-
 drivers/nfc/pn544/i2c.c                            | 221 ++------
 drivers/nfc/port100.c                              |  44 +-
 drivers/nfc/st21nfca/core.c                        |  12 +-
 drivers/nfc/st21nfca/i2c.c                         | 123 +----
 drivers/nfc/trf7970a.c                             |  98 +++-
 include/linux/platform_data/pn544.h                |  43 --
 include/linux/platform_data/st21nfca.h             |  33 --
 include/net/nfc/nfc.h                              |   1 +
 net/nfc/netlink.c                                  |  24 +-
 23 files changed, 289 insertions(+), 1063 deletions(-)
 delete mode 100644 drivers/nfc/nfcwilink.c
 delete mode 100644 include/linux/platform_data/pn544.h
 delete mode 100644 include/linux/platform_data/st21nfca.h
