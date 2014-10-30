From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 net-next 0/2] sunvnet: Use multiple Tx queues.
Date: Thu, 30 Oct 2014 12:45:47 -0400
Message-ID: <20141030164547.GE650@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45343 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760420AbaJ3Qpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:45:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


v2: moved tcp fix out of this series per David Miller feedback

The primary objective of this patch-set is to address the suggestion from
  http://marc.info/?l=linux-netdev&m=140790778931563&w=2
With the changes in Patch 2, every vnet_port will get  packets from 
a single tx-queue, and flow-control/head-of-line-blocking is 
confined to the vnet_ports that share that tx queue (as opposed to 
flow-controlling *all* peers).

Patch 1 is an optimization that resets the DATA_READY bit when
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
