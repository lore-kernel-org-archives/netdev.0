From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 0/3] Fixes T5 adapter init, due to incorrect FW version check
Date: Thu, 28 Nov 2013 19:22:11 +0530
Message-ID: <1385646734-3576-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17371 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754567Ab3K1O2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 09:28:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series fixes, Chelsio T5 adapter initialization failure due to
incorrect firmware version check. This patch series modifies the firmware
flashing mechanism for T4/T5 adapter. It adds a new module parameter
t4_fw_install to control firmware flashing.

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


Hariprasad Shenai (3):
  cxgb4: Much cleaner implementation of is_t4()/is_t5()
  cxgb4vf: added much cleaner implementation of is_t4()
  cxgb4: Add new scheme for T4/T5 firmware upgradation

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  83 +++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 287 +++++++++++----------
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  12 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 246 ++++++++++++------
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  14 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   7 +-
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |   1 -
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  15 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  24 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   4 +-
 11 files changed, 424 insertions(+), 271 deletions(-)

-- 
1.8.0
