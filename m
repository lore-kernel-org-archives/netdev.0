From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/6 net-2.6.26] [UDP]: No need to check afinfo != NULL in udp_proc_(un)register.
Date: Thu, 27 Mar 2008 17:11:34 +0300
Message-ID: <1206627098-2456-2-git-send-email-den@openvz.org>
References: <1206627041.2109.15.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39665 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755832AbYC0OLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 10:11:09 -0400
In-Reply-To: <1206627041.2109.15.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp_proc_register/udp_proc_unregister are called with a static pointer only.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/udp.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6d740ad..c05f45b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1631,8 +1631,6 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 	struct proc_dir_entry *p;
 	int rc = 0;
 
-	if (!afinfo)
-		return -EINVAL;
 	afinfo->seq_fops->owner		= afinfo->owner;
 	afinfo->seq_fops->open		= udp_seq_open;
 	afinfo->seq_fops->read		= seq_read;
@@ -1649,8 +1647,6 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 
 void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo)
 {
-	if (!afinfo)
-		return;
 	proc_net_remove(net, afinfo->name);
 	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
-- 
1.5.3.rc5

