From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 0/3 net-next] sunvnet: edge-case/race-conditions bug fixes
Date: Sat, 8 Nov 2014 20:41:43 -0500
Message-ID: <20141109014143.GB31217@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, david.stevens@oracle.com
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23073 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaKIBlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2014 20:41:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series contains fixes for race-conditions in sunvnet,
that can encountered when there is a difference in latency between
producer and consumer.

Patch 1 addresses a case when the STOPPED LDC ack from a peer is
processed before vnet_start_xmit can finish updating the dr->prod
state. 

Patch 2 fixes the edge-case when outgoing data and incoming
stopped-ack cross each other in flight. 

Patch 3 adds a missing rcu_read_unlock(), found by code-inspection.


Sowmini Varadhan (3):
  Fix race between vnet_start_xmit() and vnet_ack()
  vnet_ack() should check if !start_cons to send a missed trigger
  Add missing rcu_read_unlock() in vnet_start_xmit

 drivers/net/ethernet/sun/sunvnet.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

-- 
1.8.4.2
