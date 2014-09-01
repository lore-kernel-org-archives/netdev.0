From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 00/12] be2net: patch set
Date: Mon, 1 Sep 2014 11:54:12 +0530
Message-ID: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:19158 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbaIAGVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:21:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 adds a few new log messages to help debugging in failure cases.

Patch 2 uses new macros for parsing RX/TX completions and TX wrbs to
help shorten the lines.

Patch 3 adds a description for the RX counter rx_input_fifo_overflow_drop.

Patch 4 adds TX completion error statistics reporting via ethtool.

Patch 5 adds a dma_mapping_error counter and its reporting via ethtool.

Patch 6 fixes up log messages in the Lancer FW download path.

Patch 7 replaces gotos with direct return statements.

Patch 8 cleans up be_change_mtu() code by using a new macro BE_MAX_MTU

Patch 9 makes be_cmd_get_regs() routine to return an integer status
similar to other FW cmd routines in be_cmds.c

Patch 10 gets rid of TX budget as enforcing a budget on TX completion
processing in NAPI is neither suggested nor it provides a performance benefit.

Patch 11 defines and uses a new macro for_all_tx_queues_on_eq() similar
to the RX processing code.

Patch 12 queries max_tx_qs from the FW for BE3 super-nic profiles. 
For those profiles, the driver cannot assume a constant BE3_MAX_TX_QS value,
as the value may change for each function.

Please consider applying this patch set to the net-next tree. Thanks!

Kalesh AP (4):
  be2net: Add TX completion error statistics in ethtool
  be2net: fix log messages in lancer FW download path
  be2net: remove unncessary gotos
  be2net: define BE_MAX_MTU

Sathya Perla (5):
  be2net: add a few log messages
  be2net: shorten AMAP_GET/SET_BITS() macro calls
  be2net: add a description for counter rx_input_fifo_overflow_drop
  be2net: get rid of TX budget
  be2net: define macro for_all_tx_queues_on_eq()

Suresh Reddy (1):
  be2net: query max_tx_qs for BE3 super-nic profile from FW

Vasundhara Volam (2):
  be2net: Add a dma_mapping_error counter in ethtool
  be2net: make be_cmd_get_regs() return a status

 drivers/net/ethernet/emulex/benet/be.h         |   28 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   14 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   35 +++
 drivers/net/ethernet/emulex/benet/be_hw.h      |   12 +
 drivers/net/ethernet/emulex/benet/be_main.c    |  282 +++++++++++++-----------
 6 files changed, 232 insertions(+), 141 deletions(-)
