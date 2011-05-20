From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch 2/3] bridge: call NETDEV_JOIN notifiers when add a slave
Date: Fri, 20 May 2011 15:39:11 +0800
Message-ID: <1305877152-30970-2-git-send-email-amwang@redhat.com>
References: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934230Ab1ETHjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2011 03:39:16 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p4K7dGXX031512
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 20 May 2011 03:39:16 -0400
In-Reply-To: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the previous patch I added NETDEV_JOIN, now
we can notify netconsole when adding a device to a bridge too.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>

---
 net/bridge/br_if.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 5dbdfdf..d5147dd 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -338,6 +338,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
+	call_netdevice_notifiers(NETDEV_JOIN, dev);
+
 	err = dev_set_promiscuity(dev, 1);
 	if (err)
 		goto put_back;
-- 
1.7.1

