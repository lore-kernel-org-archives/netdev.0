From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/4] qed: RocE & iSCSI infrastructure
Date: Fri, 3 Jun 2016 14:35:31 +0300
Message-ID: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Rajesh.Borundia@qlogic.com>, <shyam.sundar@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49266 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752497AbcFCLfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 07:35:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We plan on sending 2 new protocol drivers in the imminent future -
both our RoCE [qedr] and iSCSI [qedi] drivers. As both submissions
would be rather massive and in order to avoid collisions between them,
the common infrastructure on the qed side was prepared as an independent
patch-series to be sent ahead of those 2 submissions.

This patch series introduces in QED 2 new 'ids' - one for iscsi and
one for roce. It then goes and adds logic required for configuring
said protocols in HW. Notice it *doesn't* actually add any client using
said ids, but rather only the infrastructure to allow their later usage.

What this patch doesn't contain is the slowpath protocol-configuration
toward the firmware. I.e., it contains register-setting logic, memory
allocations, etc., but not actual flow-related configuration specific
to the protocl. Those would be sent as part of the protocol driver
submissions.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Yuval Mintz (4):
  qed: Revisit chain implementation
  qed: Add common HSI for new protocols
  qed: Add iscsi/rdma personalities
  qed: Initialize hardware for new protocols

 drivers/net/ethernet/qlogic/qed/qed.h             |   13 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c         | 1347 ++++++++-
 drivers/net/ethernet/qlogic/qed/qed_cxt.h         |   24 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  474 +++-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |    8 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         | 3014 ++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_hw.c          |   26 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.h          |   12 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c        |    5 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |   13 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |   33 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |   26 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |   22 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c         |   40 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c      |    6 +-
 include/linux/qed/common_hsi.h                    |  194 +-
 include/linux/qed/iscsi_common.h                  | 1439 ++++++++++
 include/linux/qed/qed_chain.h                     |  553 ++--
 include/linux/qed/qed_if.h                        |   68 +-
 include/linux/qed/rdma_common.h                   |   44 +
 include/linux/qed/roce_common.h                   |   17 +
 include/linux/qed/storage_common.h                |   91 +
 include/linux/qed/tcp_common.h                    |  226 ++
 23 files changed, 7312 insertions(+), 383 deletions(-)
 create mode 100644 include/linux/qed/iscsi_common.h
 create mode 100644 include/linux/qed/rdma_common.h
 create mode 100644 include/linux/qed/roce_common.h
 create mode 100644 include/linux/qed/storage_common.h
 create mode 100644 include/linux/qed/tcp_common.h

-- 
1.9.3
