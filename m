From: Tom Goff <thomas.goff@boeing.com>
Subject: [PATCH] netdev: don't always reset iflink when registering
Date: Fri, 19 Mar 2010 18:39:17 -0700
Message-ID: <20100320013917.GB13239@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:53862 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab0CTCD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 22:03:29 -0400
Received: from blv-av-01.boeing.com (blv-av-01.boeing.com [130.247.48.231])
	by stl-smtpout-01.ns.cs.boeing.com (8.14.4/8.14.4/8.14.4/SMTPOUT) with ESMTP id o2K1dJJg023680
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 20:39:19 -0500 (CDT)
Received: from blv-av-01.boeing.com (localhost [127.0.0.1])
	by blv-av-01.boeing.com (8.14.4/8.14.4/DOWNSTREAM_RELAY) with ESMTP id o2K1dID0021731
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 18:39:19 -0700 (PDT)
Received: from packet.blv.boeing.com (packet.blv.boeing.com [130.42.97.136])
	by blv-av-01.boeing.com (8.14.4/8.14.4/UPSTREAM_RELAY) with SMTP id o2K1dHUC021674
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 18:39:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bound tunnel devices set their iflink to the ifindex of the underlying
network interface when created.  It shouldn't be reset by the
registration process.

Signed-off-by: Tom Goff <thomas.goff@boeing.com>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 59d4394..c00d625 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5067,7 +5067,8 @@ int register_netdevice(struct net_device *dev)
 	netdev_set_addr_lockdep_class(dev);
 	netdev_init_queue_locks(dev);
 
-	dev->iflink = -1;
+	if (dev->iflink <= 0)
+		dev->iflink = -1;
 
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
-- 
1.6.3.3

