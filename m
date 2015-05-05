From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/6] Trivial fixes and changes for SGE
Date: Tue,  5 May 2015 14:59:50 +0530
Message-ID: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19822 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750756AbbEEERX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 00:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following.
Discard packet if length is greater than MTU, move sge monitor code to a
new routine, add device node to ULD info, add congestion notification from
SGE for ingress queue and freelists and for T5, setting up the Congestion
Manager values of the new RX Ethernet Queue is done by firmware now.

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

V2: Align parenthesis for PATCH 2/6 and PATCH 5/6

Hariprasad Shenai (6):
  cxgb4: Make sure that Freelist size is larger than Egress Congestion
    Threshold
  cxgb4: Enable congestion notification from SGE for IQs and FLs.
  cxgb4: Pass in a Congestion Channel Map to t4_sge_alloc_rxq()
  cxgb4: Add device node to ULD info
  cxgb4: Move SGE Ingress DMA state monitor code to a new routine
  cxgb4: Discard the packet if the length is greater than mtu

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  26 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  11 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   1 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 160 ++++++++++++------------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 133 +++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h  |   9 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   3 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c      |  15 ++-
 8 files changed, 262 insertions(+), 96 deletions(-)

-- 
2.3.4
