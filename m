From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCHv2 0/2] Resolve packet capturing on macvlan lowerdev
Date: Thu, 28 Apr 2011 20:22:30 -0400
Message-ID: <1304036552-1589-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>,
	Patrick McHardy <kaber@trash.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:41243 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522Ab1D2Ads (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 20:33:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change in v2: Declare variables in basic block before other code appears

The following two patches address situations where macvlan interfaces on 
the same lowerdev are created inside separate containers/namespaces, and 
traffic between these interfaces needs to be captured by monitoring the 
lowerdev outside the containers/namespaces using tcpdump or Wireshark. 
The only case where this doesn't work now is for unicast frames when the 
macvlan interfaces are operating in bridge mode; this fixes that case.

Should the dev_queue_xmit_nit function be renamed to something more 
meaningful, which would indicate its role in sending outgoing frames to 
AF_PACKET sockets? It is currently a misnomer: this function used to be 
invoked by dev_queue_xmit, but that is no longer the case.

Thanks,

David

David Ward (2):
  net: Export dev_queue_xmit_nit for use by macvlan driver
  macvlan: Send frames to AF_PACKET sockets attached to lowerdev

 drivers/net/macvlan.c     |    5 ++++-
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   14 +++++++++-----
 3 files changed, 15 insertions(+), 6 deletions(-)

-- 
1.7.4.4

