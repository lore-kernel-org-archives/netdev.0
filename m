From: Manish Rangankar <manish.rangankar@cavium.com>
Subject: [PATCH v3 0/3] Add QLogic FastLinQ iSCSI (qedi) driver.
Date: Thu, 1 Dec 2016 00:21:05 -0800
Message-ID: <1480580468-31567-1-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>, <Yuval.Mintz@cavium.com>
To: <martin.petersen@oracle.com>, <lduncan@suse.com>,
        <cleech@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0060.outbound.protection.outlook.com ([104.47.33.60]:16873
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750775AbcLAIhL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 03:37:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

    net tree base: Merge of net and net-next as of 11/29/2016

Changes from RFC v2:

  1. qedi patches are squashed into single patch to prevent krobot
     warning.
  2. Fixed 'hw_p_cpuq' incompatible pointer type. 
  3. Fixed sparse incompatible types in comparison expression. 
  4. Misc fixes with latest 'checkpatch --strict' option.
  5. Remove int_mode option from MODULE_PARAM.
  6. Prefix all MODULE_PARAM params with qedi_*.
  7. Use CONFIG_QED_ISCSI instead of CONFIG_QEDI
  8. Added bad task mem access fix.

Manish Rangankar (1):
  qedi: Add QLogic FastLinQ offload iSCSI driver framework.

Yuval Mintz (2):
  qed: Add support for hardware offloaded iSCSI.
  qed: Add iSCSI out of order packet handling.

 MAINTAINERS                                    |    6 +
 drivers/net/ethernet/qlogic/Kconfig            |    3 +
 drivers/net/ethernet/qlogic/qed/Makefile       |    1 +
 drivers/net/ethernet/qlogic/qed/qed.h          |    8 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |   22 +
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c    | 1277 +++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iscsi.h    |   52 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      |  555 +++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h      |    9 +
 drivers/net/ethernet/qlogic/qed/qed_ooo.c      |  501 +++++
 drivers/net/ethernet/qlogic/qed/qed_ooo.h      |  176 ++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |    2 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c     |    1 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |   24 +
 drivers/scsi/Kconfig                           |    1 +
 drivers/scsi/Makefile                          |    1 +
 drivers/scsi/qedi/Kconfig                      |   10 +
 drivers/scsi/qedi/Makefile                     |    5 +
 drivers/scsi/qedi/qedi.h                       |  364 ++++
 drivers/scsi/qedi/qedi_dbg.c                   |  143 ++
 drivers/scsi/qedi/qedi_dbg.h                   |  144 ++
 drivers/scsi/qedi/qedi_debugfs.c               |  244 +++
 drivers/scsi/qedi/qedi_fw.c                    | 2378 ++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_gbl.h                   |   73 +
 drivers/scsi/qedi/qedi_hsi.h                   |   52 +
 drivers/scsi/qedi/qedi_iscsi.c                 | 1624 ++++++++++++++++
 drivers/scsi/qedi/qedi_iscsi.h                 |  232 +++
 drivers/scsi/qedi/qedi_main.c                  | 2127 +++++++++++++++++++++
 drivers/scsi/qedi/qedi_sysfs.c                 |   52 +
 drivers/scsi/qedi/qedi_version.h               |   14 +
 include/linux/qed/qed_if.h                     |    2 +
 include/linux/qed/qed_iscsi_if.h               |  229 +++
 32 files changed, 10303 insertions(+), 29 deletions(-)
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
