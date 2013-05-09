From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net v2 0/8] qlcnic: Bug fixes
Date: Thu, 9 May 2013 15:25:08 -0400
Message-ID: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0185.outbound.messaging.microsoft.com ([213.199.154.185]:59099
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761Ab3EIUEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 16:04:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Changes in v2:
* Removed access to netdev->trans_start from patch
  "qlcnic: Fix reset recovery after transmit timeout"

This patch series has following bug fixes:
* Fix a bug in unicast MAC address setting in adapter.
  Driver was not deleting older unicast MAC while adding new one.
* Fix an ethtool stats string array by adding missing string entry
  and fix a typo.
* Fix module paramter description. Bracket ')' was missing.
* Fix port status provided though 'ethtool <device>' for 83xx adapter.
* Fix reset recovery path in case of transmit timeout.
* Fix reset recovery during diagnostic tests by preserving
  current device status information.
* Fix mailbox response handling. Driver was not maintaining poll time properly.
* Fix validation of link event command.

Please apply to net.

Thanks,
Shahed

Himanshu Madhani (2):
  qlcnic: Fix missing bracket in module parameter.
  qlcnic: Fix ethtool supported port status for 83xx

Manish Chopra (2):
  qlcnic: Fix setting MAC address
  qlcnic: Fix bug in diagnostics test reset recovery path

Rajesh Borundia (2):
  qlcnic: Fix mailbox response handling.
  qlcnic: Fix validation of link event command.

Shahed Shaikh (1):
  qlcnic: Fix ethtool strings

Sony Chacko (1):
  qlcnic: Fix reset recovery after transmit timeout

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   95 +++++++++++++++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   22 +++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   54 ++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   46 ++++++++--
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    8 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    3 -
 9 files changed, 167 insertions(+), 69 deletions(-)
