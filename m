From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 07/15] bridge: add some comments for NETDEV_RELEASE
Date: Fri, 10 Aug 2012 19:24:43 +0800
Message-ID: <1344597891-32242-8-git-send-email-amwang@redhat.com>
References: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952Ab2HJLZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 07:25:38 -0400
In-Reply-To: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add comments on why we don't notify NETDEV_RELEASE.

Cc: David Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_if.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 171fd6b..1c8fdc3 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -427,6 +427,10 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	if (!p || p->br != br)
 		return -EINVAL;
 
+	/* Since more than one interface can be attached to a bridge,
+	 * there still maybe an alternate path for netconsole to use;
+	 * therefore there is no reason for a NETDEV_RELEASE event.
+	 */
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
-- 
1.7.7.6
