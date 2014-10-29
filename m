From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/3] sunvnet: Use multiple Tx queues.
Date: Wed, 29 Oct 2014 15:27:21 -0400
Message-ID: <20141029192721.GE6582@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41611 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbaJ2T10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:27:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The primary objective of this patch-set is to address the suggestion from
  http://marc.info/?l=linux-netdev&m=140790778931563&w=2
With the changes in Patch 3, every vnet_port will get  packets from 
a single tx-queue, and flow-control/head-of-line-blocking is 
confined to the vnet_ports that share that tx queue (as opposed to 
flow-controlling *all* peers).

Patch 1 is a minor correction to a comment that has a typo in 
the RFC number cited for the challenge-ack generation.

Patch 2 is an optimization that resets the DATA_READY bit when
we re-enable Rx interrupts.  This optimization lets us exit quickly 
from vnet_event_napi() when new data has not triggered an interrupt.


Sowmini Varadhan (3):
  Correction to RFC number in comment
  Reset LDC_EVENT_DATA_READY when napi completes.
  Use one Tx queue per vnet_port

 drivers/net/ethernet/sun/sunvnet.c | 95 +++++++++++++++++++++++++-------------
 drivers/net/ethernet/sun/sunvnet.h |  2 +
 net/ipv4/tcp_input.c               |  2 +-
 3 files changed, 67 insertions(+), 32 deletions(-)

-- 
1.8.4.2
