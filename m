From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/5] VXLAN offload support
Date: Mon, 10 Mar 2014 12:48:57 -0400
Message-ID: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:5520 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754079AbaCJRZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:25:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This patch series adds VXLAN offload support in qlcnic driver.

First patch defines a macro for default udp port used by vxlan module so that
it can be used by others.

Second patch reads adapter capabilities using poll mode, before adapter is
initialized and interrupts are enabled to for mailbox to work in interrupt
mode in order to enable VXLAN offloading support in adapter.

Third patch adds support for Tx offload for VXLAN traffic. It includes
support for Tx checksum, TSO for IPv4 and IPv6.

Fourth patch adds support for Rx checksum offload. This patch programmes default
udp port used by VXLAN, so that adapter can parse packets against this udp port number.

Final patch updates qlcnic version to 5.3.57

Please apply this series to net-next.

Thanks,
Shahed

Shahed Shaikh (5):
  vxlan: Make VXLAN default UDP port number available for others
  qlcnic: Get NIC capabilities using mailbox poll mode
  qlcnic: Add VXLAN Tx offload support
  qlcnic: Add VXLAN Rx offload support for 84xx
  qlcnic: Update version to 5.3.57

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  42 ++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  27 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   3 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  43 ++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   6 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 179 ++++++++++++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  14 ++
 drivers/net/vxlan.c                                |   6 +-
 include/net/vxlan.h                                |   6 +
 10 files changed, 280 insertions(+), 47 deletions(-)

-- 
1.8.3.1
