From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 0/2] Resolve packet capturing on macvlan lowerdev
Date: Thu, 21 Apr 2011 09:31:31 -0400
Message-ID: <1303392693-1350-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:37566 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752969Ab1DUNhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 09:37:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

 drivers/net/macvlan.c     |    1 +
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   14 +++++++++-----
 3 files changed, 12 insertions(+), 5 deletions(-)

-- 
1.7.4

