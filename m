From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] decnet: handle a failure in neigh_parms_alloc
Date: Wed, 24 Jan 2007 13:09:40 -0700
Message-ID: <m13b601917.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Whitehouse <steve@chygwyn.com>, davem@davemloft.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:38651 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbXAXUKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 15:10:09 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


While enhancing the neighbour code to handle multiple network
namespaces I noticed that decnet is assuming neigh_parms_alloc
will allways succeed, which is clearly wrong.  So handle the
failure.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/decnet/dn_dev.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 324eb47..f6a2b2a 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1149,6 +1149,11 @@ struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
 	}
 
 	dn_db->neigh_parms = neigh_parms_alloc(dev, &dn_neigh_table);
+	if (!dn_db->neigh_parms) {
+		dev->dn_ptr = NULL;
+		kfree(dn_db);
+		return NULL;
+	}
 
 	dn_dev_sysctl_register(dev, &dn_db->parms);
 
-- 
1.4.4.1.g278f

