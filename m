From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 0/3] cxgb4/cxgb4vf: Misc. fixes for cxgb4vf
Date: Fri,  7 Nov 2014 17:06:28 +0530
Message-ID: <1415360191-25395-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:34364
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751437AbaKGLas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 06:30:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

For T5 use Packing and Padding Boundaries for SGE DMA transfers, move
fl_starve_thres to adpater structure, since they are different for each
adapter. The cxgb4vf driver's Free List Starvation Threshold needs to be larger
than the SGE's Egress Congestion Threshold or we'll end up in a mutual stall
where the driver waits for Ingress Packets to drive replacing Free List
Pointers and the SGE waits for Free List Pointers before pushing Ingress
Packets to the host.

The patches series is created against 'net' tree.
And includes patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (3):
  cxgb4vf: Move fl_starv_thres into adapter->sge data structure
  cxgb4/cxgb4vf: For T5 use Packing and Padding Boundaries for SGE DMA
    transfers
  cxgb4vf: FL Starvation Threshold needs to be larger than the SGE's
    Egress Congestion Threshold

 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   30 ++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   51 +++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   10 ++
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |    8 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  136 +++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    2 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   28 ++++-
 7 files changed, 209 insertions(+), 56 deletions(-)
