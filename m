From: Thomas Graf <tgraf@suug.ch>
Subject: [PKT_SCHED]: act_api: Fix module leak while flushing actions
Date: Sun, 9 Jul 2006 16:20:43 +0200
Message-ID: <20060709142043.GN14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53473 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932451AbWGIOUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 10:20:22 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Module reference needs to be given back if message header
construction fails.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/net/sched/act_api.c
===================================================================
--- net-2.6.git.orig/net/sched/act_api.c
+++ net-2.6.git/net/sched/act_api.c
@@ -602,8 +602,8 @@ static int tca_action_flush(struct rtatt
 	return err;
 
 rtattr_failure:
-	module_put(a->ops->owner);
 nlmsg_failure:
+	module_put(a->ops->owner);
 err_out:
 	kfree_skb(skb);
 	kfree(a);
