From: "Dupuis, Chad" <chad.dupuis@cavium.com>
Subject: [PATCH RFC 0/5] Add QLogic FastLinQ FCoE (qedf) driver
Date: Fri, 23 Dec 2016 11:17:03 -0800
Message-ID: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <fcoe-devel@open-fcoe.org>,
        <netdev@vger.kernel.org>, <yuval.mintz@cavium.com>,
        <QLogic-Storage-Upstream@cavium.com>
To: <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0046.outbound.protection.outlook.com ([104.47.42.46]:51232
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758095AbcLWTcw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Dec 2016 14:32:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dupuis, Chad" <chad.dupuis@cavium.com>

This series introduces the hardware offload FCoE initiator driver for the
41000 Series Converged Network Adapters (579xx chip) by QLogic. The overall
driver design includes a common module ('qed') and protocol specific
dependent modules ('qedf' for FCoE).

This driver uses the kernel components of libfc and libfcoe as is and does not
Make use of the open-fcoe user space components.  Therefore, no changes will need to be
Made to any open-fcoe components.

The 'qed' common module, under drivers/net/ethernet/qlogic/qed/, is
enhanced with functionality required for FCoE support.

Arun Easi (1):
  qed: Add support for hardware offloaded FCoE.

Dupuis, Chad (4):
  qedf: Add QLogic FastLinQ offload FCoE driver framework.
  qedf: Add offloaded I/O request functions.
  qedf: Add offload ELS request handling.
  qedf: Add FIP request handling.qdevelop_dec13_qedf

 MAINTAINERS                                       |    6 +
 drivers/net/ethernet/qlogic/Kconfig               |    3 +
 drivers/net/ethernet/qlogic/qed/Makefile          |    1 +
 drivers/net/ethernet/qlogic/qed/qed.h             |   11 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c         |   98 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.h         |    3 +
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c        |   11 +
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h        |    1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  205 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |   42 +
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c        |  990 ++++++
 drivers/net/ethernet/qlogic/qed/qed_fcoe.h        |   52 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |  781 ++++-
 drivers/net/ethernet/qlogic/qed/qed_hw.c          |    3 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.c         |   25 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.h         |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c        |    7 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |    3 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.h         |    1 +
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |    8 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |    4 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |    3 +
 drivers/scsi/Kconfig                              |    1 +
 drivers/scsi/qedf/Kconfig                         |   11 +
 drivers/scsi/qedf/Makefile                        |    5 +
 drivers/scsi/qedf/qedf.h                          |  555 ++++
 drivers/scsi/qedf/qedf_attr.c                     |  165 +
 drivers/scsi/qedf/qedf_dbg.c                      |  192 ++
 drivers/scsi/qedf/qedf_dbg.h                      |  153 +
 drivers/scsi/qedf/qedf_debugfs.c                  |  472 +++
 drivers/scsi/qedf/qedf_els.c                      |  984 ++++++
 drivers/scsi/qedf/qedf_fip.c                      |  267 ++
 drivers/scsi/qedf/qedf_hsi.h                      |  427 +++
 drivers/scsi/qedf/qedf_io.c                       | 2303 ++++++++++++++
 drivers/scsi/qedf/qedf_main.c                     | 3519 +++++++++++++++++++++
 drivers/scsi/qedf/qedf_version.h                  |   15 +
 include/linux/qed/common_hsi.h                    |   10 +-
 include/linux/qed/fcoe_common.h                   |  715 +++++
 include/linux/qed/qed_fcoe_if.h                   |  145 +
 include/linux/qed/qed_if.h                        |   39 +
 40 files changed, 12227 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_fcoe.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_fcoe.h
 create mode 100644 drivers/scsi/qedf/Kconfig
 create mode 100644 drivers/scsi/qedf/Makefile
 create mode 100644 drivers/scsi/qedf/qedf.h
 create mode 100644 drivers/scsi/qedf/qedf_attr.c
 create mode 100644 drivers/scsi/qedf/qedf_dbg.c
 create mode 100644 drivers/scsi/qedf/qedf_dbg.h
 create mode 100644 drivers/scsi/qedf/qedf_debugfs.c
 create mode 100644 drivers/scsi/qedf/qedf_els.c
 create mode 100644 drivers/scsi/qedf/qedf_fip.c
 create mode 100644 drivers/scsi/qedf/qedf_hsi.h
 create mode 100644 drivers/scsi/qedf/qedf_io.c
 create mode 100644 drivers/scsi/qedf/qedf_main.c
 create mode 100644 drivers/scsi/qedf/qedf_version.h
 create mode 100644 include/linux/qed/fcoe_common.h
 create mode 100644 include/linux/qed/qed_fcoe_if.h

-- 
1.8.5.6
