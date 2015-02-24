From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 0/8] Adds Intel FieldsPeak NFC solution driver
Date: Tue, 24 Feb 2015 12:01:44 +0200
Message-ID: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for Intel's FieldsPeak NFC solution.
The device is enumerated with ACPI and platform init.

In order to implement the driver the nci_core_conn_create was
modified in order to report the ID of the newly created connection.
Fixed a bug that prevented to close a connection from the driver while
the dev was down.

The max packet size of a connection can be retrieved by the driver.

The init, reset NCI functions can be called from the driver. The driver
can also send command to the device using the NFC subsystem using the
request - response blocking method.

Robert Dolca (8):
  NFC: NCI: Allow connection close with dev down
  NFC: NCI: Exporting NFC command and data send API
  NFC: NCI: Adds NCI init and reset API for drivers
  NFC: NCI: Add a special nci_request for driver
  NFC: NCI: Don't call setup if previous NCI request failed
  NFC: NCI: Add function to get max packet size for conn
  NFC: NCI: Adds a way to get the new connection ID
  NFC: Add Intel FieldsPeak NFC solution driver

 drivers/nfc/Kconfig                |   1 +
 drivers/nfc/fdp/Kconfig            |  22 ++
 drivers/nfc/fdp/Makefile           |  10 +
 drivers/nfc/fdp/cmd.c              | 196 +++++++++++++++
 drivers/nfc/fdp/core.c             | 503 +++++++++++++++++++++++++++++++++++++
 drivers/nfc/fdp/fdp.h              | 115 +++++++++
 drivers/nfc/fdp/i2c.c              | 454 +++++++++++++++++++++++++++++++++
 drivers/nfc/fdp/ntf.c              |  68 +++++
 drivers/nfc/fdp/rsp.c              | 117 +++++++++
 drivers/nfc/st21nfcb/st21nfcb_se.c |   2 +-
 include/linux/platform_data/fdp.h  |  33 +++
 include/net/nfc/nci_core.h         |  18 +-
 net/nfc/nci/core.c                 |  53 +++-
 net/nfc/nci/data.c                 |  13 +
 net/nfc/nci/rsp.c                  |   6 +
 15 files changed, 1601 insertions(+), 10 deletions(-)
 create mode 100644 drivers/nfc/fdp/Kconfig
 create mode 100644 drivers/nfc/fdp/Makefile
 create mode 100644 drivers/nfc/fdp/cmd.c
 create mode 100644 drivers/nfc/fdp/core.c
 create mode 100644 drivers/nfc/fdp/fdp.h
 create mode 100644 drivers/nfc/fdp/i2c.c
 create mode 100644 drivers/nfc/fdp/ntf.c
 create mode 100644 drivers/nfc/fdp/rsp.c
 create mode 100644 include/linux/platform_data/fdp.h

-- 
1.9.1
