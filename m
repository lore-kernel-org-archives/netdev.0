From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/8] cxgb4: minor fixes, decode msgs and code refactor for few functions
Date: Tue, 26 Apr 2016 20:10:21 +0530
Message-ID: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:6384 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752394AbcDZOgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series adds new routine to get adapter information and removes
some redundant messages logged in dmesg. Fixes race while freeing tx
descriptors. Decodes module type and link down reason codes obtained from
firmware. Refactor port initialization and FW_PORT_CMD handling. Pass
correct port id in DCB message handler to obtain netdev associated. 

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (8):
  cxgb4: add new routine to get adapter info
  cxgb4: Add llseek operation for flash debugfs entry
  cxgb4: Avoids race and deadlock while freeing tx descriptor
  cxgb4: Properly decode port module type
  cxgb4: Refactor t4_port_init function
  cxgb4: DCB message handler needs to use correct portid to netdev
    mapping
  cxgb4: Don't assume FW_PORT_CMD reply is always port info msg
  cxgb4: Decode link down reason code obtained from firmware

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   8 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c     |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  94 +++++++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 249 ++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   7 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   5 +
 8 files changed, 281 insertions(+), 87 deletions(-)

-- 
2.3.4
