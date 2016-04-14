From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net-next 0/5] qed/qede: Add tunneling support
Date: Thu, 14 Apr 2016 01:38:28 -0400
Message-ID: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39296 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751716AbcDNGUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 02:20:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series adds support for VXLAN, GRE and GENEVE tunnels
to be used over this driver. With this support, adapter can perform
TSO offload, inner/outer checksums offloads on TX and RX for
encapsulated packets.

V1->V2 [ Comments from Jesse Gross incorporated ]
* Drop general infrastructure change patch.
  "net: Make vxlan/geneve default udp ports public"
* Remove by default Linux default UDP ports configurations in driver.
  Instead, use general registration APIs for UDP port configurations
* Removing .ndo_features_check - we will add it later with proper change.

Please consider applying this series to net-next.

Thanks,
Manish

Manish Chopra (5):
  qed: Add infrastructure support for tunneling
  qed/qede: Add VXLAN tunnel slowpath configuration support
  qed/qede: Add GENEVE tunnel slowpath configuration support
  qed: Enable GRE tunnel slowpath configuration
  qede: Add fastpath support for tunneling

 drivers/net/ethernet/qlogic/Kconfig                |  21 ++
 drivers/net/ethernet/qlogic/qed/qed.h              |  46 ++++
 drivers/net/ethernet/qlogic/qed/qed_dev.c          |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h      |   2 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          |  51 ++++-
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    | 127 ++++++++++
 drivers/net/ethernet/qlogic/qed/qed_l2.c           |  31 +++
 drivers/net/ethernet/qlogic/qed/qed_main.c         |  15 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |  31 +++
 drivers/net/ethernet/qlogic/qed/qed_sp.h           |   7 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c  | 255 +++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede.h            |   7 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c       | 218 +++++++++++++++++-
 include/linux/qed/qed_eth_if.h                     |  10 +
 14 files changed, 811 insertions(+), 16 deletions(-)

-- 
2.7.2
