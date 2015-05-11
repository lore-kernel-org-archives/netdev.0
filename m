From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] net: Fix ifdef typo in net_device definition
Date: Mon, 11 May 2015 11:31:52 -0700
Message-ID: <20150511183152.13432.73713.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42825 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbbEKScH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 14:32:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While trying to build for some performance testing I received the error
message below multiple times:

include/linux/netdevice.h:1658:5: warning: "CONFIG_NET_CLS_ACT" is not defined [-Wundef]
 #if CONFIG_NET_CLS_ACT

It looks like this was just a typo and should have been "#ifdef" instead of
"#if".

Fixes: d2788d34885d4 ("net: sched: further simplify handle_ing")
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c4e1caf6056f..a6d706b2a947 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1655,7 +1655,7 @@ struct net_device {
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
 
-#if CONFIG_NET_CLS_ACT
+#ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto __rcu  *ingress_cl_list;
 #endif
 	struct netdev_queue __rcu *ingress_queue;
