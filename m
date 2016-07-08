From: Varun Prakash <varun@chelsio.com>
Subject: [net-next 0/6] common library for Chelsio drivers
Date: Fri,  8 Jul 2016 23:03:53 +0530
Message-ID: <cover.1467998292.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	varun@chelsio.com
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

 This patch series adds common library module(libcxgb.ko)
for Chelsio drivers to remove duplicate code.

This series moves common iSCSI DDP Page Pod manager
code from cxgb4.ko to libcxgb.ko, earlier this code
was used by only cxgbit.ko now it is used by
three Chelsio iSCSI drivers cxgb3i, cxgb4i, cxgbit.

In future this module will have common connection
management and hardware specific code that can
be shared by multiple Chelsio drivers(cxgb4,
csiostor, iw_cxgb4, cxgb4i, cxgbit).

Please review.

Thanks
Varun

Varun Prakash (6):
  libcxgb: add library module for Chelsio drivers
  cxgb3i,cxgb4i,libcxgbi: remove iSCSI DDP support
  cxgb4i,libcxgbi: add iSCSI DDP support
  cxgb3i: add iSCSI DDP support
  libcxgb: export ppm release and tagmask set api
  cxgb3i,cxgb4i: fix symbol not declared sparse warning

 drivers/net/ethernet/chelsio/Kconfig               |  18 +-
 drivers/net/ethernet/chelsio/Makefile              |   1 +
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   1 -
 drivers/net/ethernet/chelsio/libcxgb/Makefile      |   3 +
 .../{cxgb4/cxgb4_ppm.c => libcxgb/libcxgb_ppm.c}   |  27 +-
 .../{cxgb4/cxgb4_ppm.h => libcxgb/libcxgb_ppm.h}   |   8 +-
 drivers/scsi/cxgbi/Makefile                        |   2 +
 drivers/scsi/cxgbi/cxgb3i/Kbuild                   |   1 +
 drivers/scsi/cxgbi/cxgb3i/Kconfig                  |   1 +
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c                 | 164 +++--
 drivers/scsi/cxgbi/cxgb4i/Kbuild                   |   1 +
 drivers/scsi/cxgbi/cxgb4i/Kconfig                  |   1 +
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 | 203 +++---
 drivers/scsi/cxgbi/libcxgbi.c                      | 734 +++++++--------------
 drivers/scsi/cxgbi/libcxgbi.h                      | 188 +-----
 drivers/target/iscsi/cxgbit/Kconfig                |   2 +-
 drivers/target/iscsi/cxgbit/Makefile               |   1 +
 drivers/target/iscsi/cxgbit/cxgbit.h               |   2 +-
 drivers/target/iscsi/cxgbit/cxgbit_main.c          |   2 +
 19 files changed, 500 insertions(+), 860 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/libcxgb/Makefile
 rename drivers/net/ethernet/chelsio/{cxgb4/cxgb4_ppm.c => libcxgb/libcxgb_ppm.c} (95%)
 rename drivers/net/ethernet/chelsio/{cxgb4/cxgb4_ppm.h => libcxgb/libcxgb_ppm.h} (98%)

-- 
2.0.2

