From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net v2 0/3] Fixes T5 adapter init, due to incorrect FW version check
Date: Tue,  3 Dec 2013 17:05:55 +0530
Message-ID: <1386070558-21521-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13159 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205Ab3LCLoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 06:44:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series fixes, Chelsio T5 adapter initialization failure due to
incorrect firmware version check. This patch series modifies the firmware
flashing mechanism for T4/T5 adapter.

The patch series moves chip type from struct adapter to struct adapter_params.
It changes the references of chip type in cxgb4 and cxgb4vf drivers such that
build failure is avoided.

Patch 3/3 is dependent on patch 1/3
Patch 2/3 is also dependent on patch 1/3

We would like to request this patch series to get merged via David Miller's
'net' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

V2: Removed module parameter t4_fw_install

Hariprasad Shenai (3):
  cxgb4: Much cleaner implementation of is_t4()/is_t5()
  cxgb4vf: added much cleaner implementation of is_t4()
  cxgb4: Add new scheme to update T4/T5 firmware

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  82 +++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 278 +++++++++++----------
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  12 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 230 ++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  14 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   7 +-
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |   1 -
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  15 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  24 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   4 +-
 11 files changed, 397 insertions(+), 272 deletions(-)

-- 
1.8.0
