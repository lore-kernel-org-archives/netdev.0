From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [GIT PULL] target for-next-merge updates for v4.6-rc1
Date: Wed, 23 Mar 2016 14:53:50 -0700
Message-ID: <1458770030.19489.11.camel@haakon3.risingtidesystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: target-devel <target-devel@vger.kernel.org>,
	Linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	Varun Prakash <varun@chelsio.com>, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <target-devel-owner@vger.kernel.org>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Linus,

Here are the target-pending for-next-merge updates for v4.6-rc1.

Please go ahead and pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/nab/target-pending.git for-next-merge

You'll hit one minor merge conflict in t4fw_api.h with net-next as
reported by SFR:

https://lkml.org/lkml/2016/2/29/34

This series contains cxgb4 driver prerequisites for supporting iscsi
segmentation offload (ISO), that will be utilized for a number of future
v4.7 developments in iscsi-target for supporting generic hw offloads.

Thank you,

--nab

Varun Prakash (12):
  cxgb4: add new ULD type CXGB4_ULD_ISCSIT
  cxgb4: allocate resources for CXGB4_ULD_ISCSIT
  cxgb4: large receive offload support
  cxgb4, iw_cxgb4: move definitions to common header file
  cxgb4, iw_cxgb4, cxgb4i: remove duplicate definitions
  cxgb4, cxgb4i: move struct cpl_rx_data_ddp definition
  cxgb4: add definitions for iSCSI target ULD
  cxgb4: update struct cxgb4_lld_info definition
  cxgb4: move VLAN_NONE macro definition
  cxgb4, iw_cxgb4: move delayed ack macro definitions
  cxgb4: add iSCSI DDP page pod manager
  cxgb4: update Kconfig and Makefile

 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h          |  99 -----
 drivers/net/ethernet/chelsio/Kconfig               |  11 +
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  27 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  34 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  97 ++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c     | 464 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h     | 310 ++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |  11 +
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |   2 -
 drivers/net/ethernet/chelsio/cxgb4/l2t.h           |   2 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  13 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        | 217 ++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   7 +
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.h                 |  17 -
 15 files changed, 1174 insertions(+), 138 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h
