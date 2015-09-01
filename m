From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v2 0/9] Adds Intel FieldsPeak NFC solution driver
Date: Tue,  1 Sep 2015 17:54:19 +0300
Message-ID: <1441119268-30654-1-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches add support for Intel's FieldsPeak NFC solution.

=46ields Peak complies with the ISO/IEC 14443A/B, 15693, 18092,
and JIS X 6319-4. It is an NCI based controller.

RF Protocols supported:
 - NFC Forum Type 1 Tags (Jewel, Topaz)
 - NFC Forum Type 2 Tags (Mifare UL)
 - NFC Forum Type 3 Tags (FeliCa)
 - NFC Forum Type 4A (ISO/IEC 14443 A-4 106kbps to 848kbps)
 - NFC Forum Type 4B (ISO/IEC 14443 B-4 106kbps to 848kbps)
 - NFCIP in passive and active modes (ISO/IEC 18092 106kbps to 424kbps)
 - B=E2=80=99 (based on ISO/IEC 14443 B-2)
 - iCLASS (based on ISO/IEC 15693-2)
 - Vicinity cards (ISO/IEC 15693-3)
 - Kovio tags (NFC Forum Type 2)

The device can be enumerated using ACPI using the id INT339A.
The 1st GPIO is the IRQ and the 2nd is the RESET pin.

Changes since v1:
 - removed .owner
 - made local functions static
 - replaced nfc_info with dev_dbg
 - make controller setup possible without OTP patch
 - removed the commint that was adding nci_init/reset and start using
   the newly added functions nci_core_init/reset
 - fixed typo and use full controller name instead of abreviation in Kc=
onfig
 - added more info about the controller in the commit message
 - moved NCI_OP_CORE_RESET_NTF, NCI_OP_CORE_GET_CONFIG_RSP and
   NCI_OP_CORE_GET_CONFIG_CMD into the core header files
 - added MODULE_DEVICE_TABLE for ACPI
 - defined FDP_FW_UPDATE_DEST 0xC2
 - release the firmware buffers
 - settings the vendor configuration and clock on post setup
 - platform data enumerations removed (ACPI enumeration left)
 - packet reception intercept logic remove
 - nci: removed "NFC: NCI: Adds NCI init and reset API for drivers"
 - nci: removed nci_send_cmd symbol export
 - nci: removed nci_request_driver and nci_req_complete_driver
 - removed mutex from driver (no need for it)
 - nci: check the setup return code before callig post_setup
 - nci: add function to allow sending core commands from driver
 - nci: Use a separate mutex for nci open and close
 - nci: mutex for: Adds a way to get the new connection ID
 - nci: Allow the driver to set handler for core nci ops

Robert Dolca (9):
  nfc: nci: Exporting nci data send API
  nfc: nci: Add function to get max packet size for conn
  nfc: nci: Define new core opcodes
  nfc: nci: Allow the driver to set handler for core nci ops
  nfc: nci: Do not call post_setup when setup fails
  nfc: nci: Add function to allow sending core commands from driver
  nfc: nci: Use a separate mutex for nci open and close
  nfc: nci: Adds a way to get the new connection ID
  nfc: Add Intel Fields Peak NFC solution driver

 drivers/nfc/Kconfig            |   1 +
 drivers/nfc/Makefile           |   1 +
 drivers/nfc/fdp/Kconfig        |  23 ++
 drivers/nfc/fdp/Makefile       |   9 +
 drivers/nfc/fdp/fdp.c          | 777 +++++++++++++++++++++++++++++++++=
++++++++
 drivers/nfc/fdp/fdp.h          |  52 +++
 drivers/nfc/fdp/i2c.c          | 416 ++++++++++++++++++++++
 drivers/nfc/st-nci/st-nci_se.c |   2 +-
 include/net/nfc/nci.h          |   7 +
 include/net/nfc/nci_core.h     |  29 +-
 net/nfc/nci/core.c             | 108 +++---
 net/nfc/nci/data.c             |  13 +
 net/nfc/nci/ntf.c              |   6 +-
 net/nfc/nci/rsp.c              |  12 +-
 14 files changed, 1403 insertions(+), 53 deletions(-)
 create mode 100644 drivers/nfc/fdp/Kconfig
 create mode 100644 drivers/nfc/fdp/Makefile
 create mode 100644 drivers/nfc/fdp/fdp.c
 create mode 100644 drivers/nfc/fdp/fdp.h
 create mode 100644 drivers/nfc/fdp/i2c.c

--=20
1.9.1
