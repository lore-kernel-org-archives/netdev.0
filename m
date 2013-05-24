From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 00/12] qlcnic: Enhancements and cleanup
Date: Fri, 24 May 2013 03:04:24 -0400
Message-ID: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:32902
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757260Ab3EXH3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:29:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch series includes following changes:
* Support for spoof check configuration per VF using
  iproute2 tool.
* Set HW mask for 8300 adapter in INT-x mode to stop generating
  interrupts.
* Updated IRQ name for 8200 and 8300 Series adapter as per
  format used by other multiqueue drivers.
* Remove qlcnic_config_npars module parameter.
* Initialize trans_work and idc_aen_work at VF probe.
* Convert netsted if-else into switch-case statement.
* Change in diagnostics routine.
* Modify reset recovery path in diag mode by providing diagnostics
  routines enough time to unwind before proceeding with reset recovery.
* Implement GET_LED_STATUS command for 82xx adapter and refactor
  qlcnic_store_beacon() to split 8200 and 8300 specific calls.
* Some cleanup and log enhancements

Please apply to net-next.

Thanks,
Shahed


Himanshu Madhani (3):
  qlcnic: Disable INT-x interrupt for 83xx on driver unload
  qlcnic: Update IRQ name for 8200 and 8300 Series adapter.
  qlcnic: Implement GET_LED_STATUS command for 82xx adapter.

Jitendra Kalsaria (1):
  qlcnic: Convert nested if-else to switch-case

Manish Chopra (2):
  qlcnic: qlcnic_get_board_name() function cleanup
  qlcnic: Enhance virtual NIC logging

Rajesh Borundia (1):
  qlcnic: Support spoof check config.

Shahed Shaikh (2):
  qlcnic: Remove qlcnic_config_npars module parameter
  qlcnic: Update version to 5.2.43

Sony Chacko (2):
  qlcnic: diagnostics routine changes
  qlcnic: modify reset recovery path in diag mode

Sucheta Chakraborty (1):
  qlcnic: Initialize trans_work and idc_aen_work at VF probe.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   27 ++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   77 +++++++-----
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   35 +++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |   39 +++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |   45 ++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   15 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   85 ++++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    2 +
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    7 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   36 ++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |  126 ++++++++++++--------
 13 files changed, 326 insertions(+), 170 deletions(-)
