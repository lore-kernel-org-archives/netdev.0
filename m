From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/7] qlcnic: Bug fixes
Date: Fri, 26 Apr 2013 08:09:36 -0400
Message-ID: <1366978183-7282-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.188] ([216.32.180.188]:58676 "EHLO
	co1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756316Ab3DZMfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 08:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch series has following bug fixes:
* Fix a bug in unicast MAC address setting in adapter.
  Driver was not deleting older unicast MAC while adding new one.
* Fix a bug in offload settings behaviour which is controlled
  through an application. LRO was not getting turned on/off when
  we turn on/off Rx checksum.
* Fix an ethtool stats string array by adding missing string entry
  and fix a typo.
* Add missing bracket ')' in module paramter description.
* Fix port status provided though 'ethtool <device>' for 83xx adapter
* Fix reset recovery path in case of transmit timeout.
* Fix reset revovery during diagnostic tests by preserving
  current device status information.

Please apply to net.

Thanks,
Shahed

Himanshu Madhani (2):
  qlcnic: Fix missing bracket in module parameter.
  qlcnic: Fix ethtool Supported port status for 83xx

Manish Chopra (3):
  qlcnic: Fix setting MAC address
  qlcnic: Fix bug in tuning offloads using QLogic application
  qlcnic: Fix bug in diagnostics test reset recovery path

Shahed Shaikh (1):
  qlcnic: Fix ethtool strings

Sony Chacko (1):
  qlcnic: Fix reset recovery after transmit timeout

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    3 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   79 +++++++++++++++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   24 ++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   52 ++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   65 +++++++++++++---
 6 files changed, 172 insertions(+), 53 deletions(-)
