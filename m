From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] net: emphasize rtnl lock required in
 call_netdevice_notifiers
Date: Tue, 20 Apr 2010 10:37:30 +0200
Message-ID: <20100420083729.GA2810@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346Ab0DTIhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 04:37:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since netdev_chain is guarded by rtnl_lock, ASSERT_RTNL should be present here
to make sure that all callers of call_netdevice_notifiers does the locking
properly.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/core/dev.c b/net/core/dev.c
index 05a2b29..a7f13a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1435,6 +1435,7 @@ EXPORT_SYMBOL(unregister_netdevice_notifier);
 
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 {
+	ASSERT_RTNL();
 	return raw_notifier_call_chain(&netdev_chain, val, dev);
 }
 
