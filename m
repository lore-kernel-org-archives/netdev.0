From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 0/8] qlcnic: Bug fixes.
Date: Mon, 16 Dec 2013 15:36:55 -0500
Message-ID: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:24224 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751636Ab3LPVJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This series contains bug fixes for mailbox handling and multi Tx queue support
for all supported adapters.

changes from v1 -> v2
o updated patch to fix usage of netif_tx_{wake,stop} api during link change
  as per David Miller's suggestion.
o Dropped patch to use spinklock per tx queue for more work.
o Added reworked patch for memory allocation failures.
o Added patch to allow capturing of dump, when auto recovery is disabled in firmware.
o Added patches for mailbox interrupt handling and debugging data for mailbox failure.

Please apply to net.

Thanks,
Himanshu

Himanshu Madhani (4):
  qlcnic: Fix usage of netif_tx_{wake,stop} api during link change.
  qlcnic: Fix diagnostic test for all adapters.
  qlcnic: Fix TSS/RSS ring validation logic.
  qlcnic: Fix TSS/RSS validation for 83xx/84xx series adapter.

Manish Chopra (2):
  qlcnic: Fix memory allocation
  qlcnic: Allow firmware dump collection when auto firmware recovery is
    disabled

Manish chopra (2):
  qlcnic: Fix mailbox processing during diagnostic test
  qlcnic: Dump mailbox registers when mailbox command times out.

 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 47 +++++++---------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  | 65 +++++++++++++---------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    | 19 +++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 10 +---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  2 +-
 6 files changed, 73 insertions(+), 71 deletions(-)

-- 
1.8.1.4
