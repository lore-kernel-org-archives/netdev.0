From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 0/6] qed/qede: Add tunneling support
Date: Sat, 9 Apr 2016 09:16:59 -0400
Message-ID: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:58175 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752996AbcDIN6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 09:58:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series adds support for VXLAN, GRE and GENEVE tunnels
to be used over this driver. With this support, adapter can perform
TSO offload, inner/outer checksums offloads on TX and RX for
encapsulated packets.

Almost all the changes in this series addresses our driver modules,
except the first patch which is for general infrastructure change.

Please consider applying this series to net-next.

Thanks,
Manish

Manish Chopra (6):
  net: Make vxlan/geneve default udp ports public
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
 drivers/net/ethernet/qlogic/qede/qede.h            |   6 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c       | 198 +++++++++++++++-
 drivers/net/geneve.c                               |   4 +-
 drivers/net/vxlan.c                                |   2 +-
 include/linux/qed/qed_eth_if.h                     |  10 +
 include/net/geneve.h                               |   1 +
 include/net/vxlan.h                                |   2 +
 18 files changed, 796 insertions(+), 19 deletions(-)

-- 
2.7.2
