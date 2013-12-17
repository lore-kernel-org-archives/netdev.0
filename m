From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 0/7] qlcnic: Refactoring and enhancements
Date: Tue, 17 Dec 2013 09:01:48 -0500
Message-ID: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:36990 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753255Ab3LQOev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 09:34:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series includes follwing changes

* Refactor DCBX code. Do not allow DCBX operations for VFs
* Issue INIT_NIC mailbox command only once
* Refactor initialize nic code path
* Allow configuration for single TX/RX queue
* VLAN enhancement for 84xx adapters
* Support for 16 virtual NIC functions for 84XX series adapters

Please apply to net-next

Thanks,
Manish


Himanshu Madhani (1):
  qlcnic: Allow single Tx/Rx queue for all adapters.

Jitendra Kalsaria (1):
  qlcnic: Support for 16 virtual NIC functions.

Manish Chopra (2):
  qlcnic: VLAN enhancement for 84XX adapters
  qlcnic: update version to 5.3.53

Sucheta Chakraborty (3):
  qlcnic: Disable DCB operations from SR-IOV VFs.
  qlcnic: Issue INIT_NIC command only once.
  qlcnic: Refactor initialize nic code path.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   45 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   78 +++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   12 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   14 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |   49 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    |   31 +---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h    |   14 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   48 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   60 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |   12 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |  248 +++++++++++++++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |  192 +++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |  118 ++++++----
 17 files changed, 635 insertions(+), 302 deletions(-)
