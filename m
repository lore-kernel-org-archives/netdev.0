From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-next-2.6 2009-08-30
Date: Sun, 30 Aug 2009 01:50:14 -0700
Message-ID: <cover.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53259 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbZH3Ivt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:51:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these are the updates for the Bluetooth subsystem for the 2.6.32 merge
window. On the driver side we have support for Marvell SDIO devices and
the Bluetooth USB driver got support for auto-suspend. On the core stack
part we have support for L2CAP enhanced retransmission mode now. The rest
are random fixes and cleanups.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

This will update the following files:

 Documentation/00-INDEX             |    2 +
 Documentation/btmrvl.txt           |  119 ++++
 drivers/bluetooth/Kconfig          |   25 +
 drivers/bluetooth/Makefile         |    6 +
 drivers/bluetooth/btmrvl_debugfs.c |  432 ++++++++++++
 drivers/bluetooth/btmrvl_drv.h     |  139 ++++
 drivers/bluetooth/btmrvl_main.c    |  624 +++++++++++++++++
 drivers/bluetooth/btmrvl_sdio.c    | 1003 ++++++++++++++++++++++++++
 drivers/bluetooth/btmrvl_sdio.h    |  108 +++
 drivers/bluetooth/btusb.c          |  198 +++++-
 drivers/bluetooth/hci_bcsp.c       |    3 +-
 include/net/bluetooth/bluetooth.h  |    5 +-
 include/net/bluetooth/hci_core.h   |   10 +-
 include/net/bluetooth/l2cap.h      |  134 ++++-
 include/net/bluetooth/rfcomm.h     |    2 +
 net/bluetooth/Kconfig              |    1 +
 net/bluetooth/hci_conn.c           |   17 +-
 net/bluetooth/hci_core.c           |    2 +-
 net/bluetooth/hci_event.c          |    2 +
 net/bluetooth/hidp/core.c          |   66 ++-
 net/bluetooth/hidp/hidp.h          |    2 +
 net/bluetooth/l2cap.c              | 1357 +++++++++++++++++++++++++++++++++---
 net/bluetooth/rfcomm/core.c        |   69 ++-
 net/bluetooth/sco.c                |   49 +-
 24 files changed, 4186 insertions(+), 189 deletions(-)
 create mode 100644 Documentation/btmrvl.txt
 create mode 100644 drivers/bluetooth/btmrvl_debugfs.c
 create mode 100644 drivers/bluetooth/btmrvl_drv.h
 create mode 100644 drivers/bluetooth/btmrvl_main.c
 create mode 100644 drivers/bluetooth/btmrvl_sdio.c
 create mode 100644 drivers/bluetooth/btmrvl_sdio.h

through these ChangeSets:

Bing Zhao (5):
    Bluetooth: Add btmrvl driver for Marvell Bluetooth devices
    Bluetooth: Add Marvell BT-over-SDIO driver
    Bluetooth: Add debugfs support to btmrvl driver
    Bluetooth: Add documentation for Marvell Bluetooth driver
    Bluetooth: Fix incorrect alignment in Marvell BT-over-SDIO driver

Gustavo F. Padovan (15):
    Bluetooth: Add configuration support for ERTM and Streaming mode
    Bluetooth: Create separate l2cap_send_disconn_req() function
    Bluetooth: Add initial support for ERTM packets transfers
    Bluetooth: Add support for Segmentation and Reassembly of SDUs
    Bluetooth: Initial support for retransmission of packets with REJ
      frames
    Bluetooth: Add support for Retransmission and Monitor Timers
    Bluetooth: Enable Streaming Mode for L2CAP
    Bluetooth: Add support for FCS option to L2CAP
    Bluetooth: Add support for L2CAP SREJ exception
    Bluetooth: Full support for receiving L2CAP SREJ frames
    Bluetooth: Add locking scheme to L2CAP timeout callbacks
    Bluetooth: Use proper *_unaligned_le{16,32} helpers for L2CAP
    Bluetooth: Acknowledge L2CAP packets when receiving RR-frames (F-bit=1)
    Bluetooth: Handle L2CAP case when the remote receiver is busy
    Bluetooth: Add support for L2CAP 'Send RRorRNR' action

Julia Lawall (1):
    Bluetooth: Add missing kmalloc NULL tests to Marvell driver

Luiz Augusto von Dentz (1):
    Bluetooth: Fix rejected connection not disconnecting ACL link

Marcel Holtmann (19):
    Bluetooth: Add proper shutdown support to SCO sockets
    Bluetooth: Disconnect HIDRAW devices on disconnect
    Bluetooth: Add extra device reference counting for connections
    Bluetooth: Let HIDP grab the device reference for connections
    Bluetooth: Fix Kconfig for Marvell Bluetooth driver
    Bluetooth: Fix compilation of Marvell driver without debugfs
    Bluetooth: Remove pointless ifdef protection for Marvell header files
    Bluetooth: Remove pointless casts from Marvell debugfs support
    Bluetooth: Some coding style cleanup for Marvell core driver
    Bluetooth: Fix complicated assignment of firmware for Marvell devices
    Bluetooth: Fix module description strings for Marvell driver
    Bluetooth: Remove private device name of Marvell SDIO driver
    Bluetooth: Fix Marvell driver to use skb_put and hci_opcode_pack
    Bluetooth: Fix last few compiler warning within Marvell core driver
    Bluetooth: Remove Enter/Leave debug statements from Marvell driver
    Bluetooth: Coding style cleanup from previous rfcomm_init bug fix
    Bluetooth: Add module option to enable L2CAP ERTM support
    Bluetooth: Allow setting of L2CAP ERTM via socket option
    Bluetooth: Add L2CAP RFC option if ERTM is enabled

Oliver Neukum (1):
    Bluetooth: Add USB autosuspend support to btusb driver

Randy Dunlap (1):
    Bluetooth: Add missing selection of CONFIG_CRC16 for L2CAP layer

Thomas Gleixner (1):
    Bluetooth: Convert hdev->req_lock to a mutex

Vikram Kandukuri (2):
    Bluetooth: Fix missing scheduling when VIRTUAL_CABLE_UNPLUG is received
    Bluetooth: Improve USB driver throughput by increasing the frame size

Wending Weng (1):
    Bluetooth: Fix false errors from bcsp_pkt_cull function

