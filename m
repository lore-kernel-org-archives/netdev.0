From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 0/8] enic updates
Date: Tue, 10 Jun 2014 00:02:45 +0530
Message-ID: <1402338773-5996-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, gvaradar@cisco.com, benve@cisco.com,
	_govind@gmx.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:64099 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbaFISdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 14:33:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes minor bugs and adds new features like Accelerated RFS,
busy_poll, tx clean-up in napi_poll.

Please apply it to net-next.

Govindarajulu Varadarajan (7):
  flow_keys: Record IP layer protocol in skb_flow_dissect()
  enic: fix return value in _vnic_dev_cmd
  enic: devcmd for adding IP 5 tuple hardware filters
  enic: alloc/free rx_cpu_rmap
  enic: Add Accelerated RFS support
  enic: add low latency socket busy_poll support
  enic: do tx cleanup in napi poll

Tony Camuso (1):
  enic: fix lockdep around devcmd_lock

 drivers/net/ethernet/cisco/enic/Makefile      |   2 +-
 drivers/net/ethernet/cisco/enic/enic.h        |  43 +++-
 drivers/net/ethernet/cisco/enic/enic_api.c    |   4 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c   | 269 ++++++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_clsf.h   |  19 ++
 drivers/net/ethernet/cisco/enic/enic_dev.c    |  80 ++++----
 drivers/net/ethernet/cisco/enic/enic_dev.h    |   4 +-
 drivers/net/ethernet/cisco/enic/enic_main.c   | 239 +++++++++++++++++------
 drivers/net/ethernet/cisco/enic/enic_res.c    |   1 +
 drivers/net/ethernet/cisco/enic/vnic_dev.c    |  65 ++++++-
 drivers/net/ethernet/cisco/enic/vnic_dev.h    |   2 +
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h |   5 +
 drivers/net/ethernet/cisco/enic/vnic_enet.h   |   2 +
 drivers/net/ethernet/cisco/enic/vnic_rq.h     | 122 ++++++++++++
 include/net/flow_keys.h                       |  14 ++
 include/net/sch_generic.h                     |   2 +-
 net/core/flow_dissector.c                     |   1 +
 17 files changed, 771 insertions(+), 103 deletions(-)
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_clsf.c
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_clsf.h

-- 
2.0.0
