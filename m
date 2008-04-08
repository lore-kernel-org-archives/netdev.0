From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [TCP]: No need to check afinfo != NULL in tcp_proc_(un)register.
Date: Tue,  8 Apr 2008 17:29:48 +0400
Message-ID: <1207661392-13570-2-git-send-email-den@openvz.org>
References: <1207661318.7171.22.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7279 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976AbYDHN3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 09:29:31 -0400
In-Reply-To: <1207661318.7171.22.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_proc_register/tcp_proc_unregister are called with a static pointer only.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/tcp_ipv4.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fc1b505..e5dd52b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2264,8 +2264,6 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 	int rc = 0;
 	struct proc_dir_entry *p;
 
-	if (!afinfo)
-		return -EINVAL;
 	afinfo->seq_fops->owner		= afinfo->owner;
 	afinfo->seq_fops->open		= tcp_seq_open;
 	afinfo->seq_fops->read		= seq_read;
@@ -2282,8 +2280,6 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 
 void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 {
-	if (!afinfo)
-		return;
 	proc_net_remove(net, afinfo->name);
 	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
-- 
1.5.3.rc5

