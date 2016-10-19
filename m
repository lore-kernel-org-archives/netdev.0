From: <manish.rangankar@cavium.com>
Subject: [RFC 0/6] Add QLogic FastLinQ iSCSI (qedi) driver.
Date: Wed, 19 Oct 2016 01:01:07 -0400
Message-ID: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <martin.petersen@oracle.com>, <jejb@linux.vnet.ibm.com>,
        <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>, <QLogic-Storage-Upstream@cavium.com>,
        Manish Rangankar <manish.rangankar@cavium.com>
To: <lduncan@suse.com>, <cleech@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:58327 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756398AbcJSFsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 01:48:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Rangankar <manish.rangankar@cavium.com>

This series introduces hardware offload iSCSI initiator driver for the
41000 Series Converged Network Adapters (579xx chip) by Qlogic. The overall
driver design includes a common module ('qed') and protocol specific
dependent modules ('qedi' for iSCSI).

This is an open iSCSI driver, modifications to open iSCSI user components
'iscsid', 'iscsiuio', etc. are required for the solution to work. The user
space changes are also in the process of being submitted.

    https://groups.google.com/forum/#!forum/open-iscsi

The 'qed' common module, under drivers/net/ethernet/qlogic/qed/, is
enhanced with functionality required for the iSCSI support. This series
is based on:

    net-next: 1b830996c1603225a96e233c3b09bf2b12607d78

qedi patches are divided logically for review purpose and individual
patches do not compile.

We really appreciate any review comments you may have on the patch series.

Manish Rangankar (4):
  qedi: Add QLogic FastLinQ offload iSCSI driver framework.
  qedi: Add LL2 iSCSI interface for offload iSCSI.
  qedi: Add support for iSCSI session management.
  qedi: Add support for data path.

Yuval Mintz (2):
  qed: Add support for hardware offloaded iSCSI.
  qed: Add iSCSI out of order packet handling.

 MAINTAINERS                                    |    6 +
 drivers/net/ethernet/qlogic/Kconfig            |    3 +
 drivers/net/ethernet/qlogic/qed/Makefile       |    1 +
 drivers/net/ethernet/qlogic/qed/qed.h          |    9 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |   25 +
 drivers/net/ethernet/qlogic/qed/qed_int.h      |    1 -
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c    | 1310 +++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iscsi.h    |   52 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c       |    1 -
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      |  594 +++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h      |    9 +
 drivers/net/ethernet/qlogic/qed/qed_main.c     |    2 -
 drivers/net/ethernet/qlogic/qed/qed_mcp.h      |    6 -
 drivers/net/ethernet/qlogic/qed/qed_ooo.c      |  510 +++++
 drivers/net/ethernet/qlogic/qed/qed_ooo.h      |  116 ++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |    2 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c     |    1 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |   24 +
 drivers/scsi/Kconfig                           |    1 +
 drivers/scsi/Makefile                          |    1 +
 drivers/scsi/qedi/Kconfig                      |   10 +
 drivers/scsi/qedi/Makefile                     |    5 +
 drivers/scsi/qedi/qedi.h                       |  359 ++++
 drivers/scsi/qedi/qedi_dbg.c                   |  143 ++
 drivers/scsi/qedi/qedi_dbg.h                   |  144 ++
 drivers/scsi/qedi/qedi_debugfs.c               |  244 +++
 drivers/scsi/qedi/qedi_fw.c                    | 2405 ++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_gbl.h                   |   73 +
 drivers/scsi/qedi/qedi_hsi.h                   |   52 +
 drivers/scsi/qedi/qedi_iscsi.c                 | 1610 ++++++++++++++++
 drivers/scsi/qedi/qedi_iscsi.h                 |  228 +++
 drivers/scsi/qedi/qedi_main.c                  | 2075 ++++++++++++++++++++
 drivers/scsi/qedi/qedi_sysfs.c                 |   52 +
 drivers/scsi/qedi/qedi_version.h               |   14 +
 include/linux/qed/qed_if.h                     |    2 +
 include/linux/qed/qed_iscsi_if.h               |  249 +++
 36 files changed, 10294 insertions(+), 45 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ooo.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ooo.h
 create mode 100644 drivers/scsi/qedi/Kconfig
 create mode 100644 drivers/scsi/qedi/Makefile
 create mode 100644 drivers/scsi/qedi/qedi.h
 create mode 100644 drivers/scsi/qedi/qedi_dbg.c
 create mode 100644 drivers/scsi/qedi/qedi_dbg.h
 create mode 100644 drivers/scsi/qedi/qedi_debugfs.c
 create mode 100644 drivers/scsi/qedi/qedi_fw.c
 create mode 100644 drivers/scsi/qedi/qedi_gbl.h
 create mode 100644 drivers/scsi/qedi/qedi_hsi.h
 create mode 100644 drivers/scsi/qedi/qedi_iscsi.c
 create mode 100644 drivers/scsi/qedi/qedi_iscsi.h
 create mode 100644 drivers/scsi/qedi/qedi_main.c
 create mode 100644 drivers/scsi/qedi/qedi_sysfs.c
 create mode 100644 drivers/scsi/qedi/qedi_version.h
 create mode 100644 include/linux/qed/qed_iscsi_if.h

-- 
1.8.3.1
