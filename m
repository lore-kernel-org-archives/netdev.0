From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v3 0/5] qlcnic: Mailbox refactoring
Date: Fri, 2 Aug 2013 00:57:38 -0400
Message-ID: <cover.1375438720.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:48611 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753398Ab3HBFZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 01:25:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This series contains following patches 

o in v2 series, we received feedback on return codes to use standard error
  codes instead of mixing custom error codes. We have modified patch for 
  loopback diagnostic test to return standard error codes.

o rest of the 3 patches in the series are for mailbox refactoring

  Current driver-firmware mailbox interface was operating in polling mode
  because of some limitations with the earlier versions of 83xx adapter
  firmware. These issues are resolved now and we are implementing the
  mailbox interface in interrupt mode.

  There are three patches which refactors mailbox handling:
  * Interrupt mode mailbox implantation.
  * Replace poll mode mailbox interfaces with interrupt mode interfaces.
  * Operate mailbox in poll mode when interrupts are not available.

changes from v2 -> v3
 * Addressed review feedback to use standard return codes for loopback
   diagnostic test.

Please consider applying these patches to net-next.

Thanks,
Himanshu

Himanshu Madhani (1):
  qlcnic: Update version to 5.2.45

Jitendra Kalsaria (1):
  qlcnic: Enhance diagnostic loopback error codes.

Manish Chopra (3):
  qlcnic: Interrupt based driver firmware mailbox mechanism
  qlcnic: Replace poll mode mailbox interface with interrupt based
    mailbox interface
  qlcnic: Enable mailbox interface in poll mode when interrupts are not
    available

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  59 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 615 +++++++++++++++------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  27 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  83 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  18 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   | 146 ++---
 8 files changed, 651 insertions(+), 309 deletions(-)

-- 
1.8.1.4
