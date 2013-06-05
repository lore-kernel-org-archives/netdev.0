From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] vxlan: fix crash on module removal
Date: Wed, 5 Jun 2013 08:37:00 -0700
Message-ID: <20130605083700.2a09e379@nehalam.linuxnetplumber.net>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
	<1370406254-6341-3-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:56982 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756053Ab3FEPhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 11:37:04 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so1954950pbc.32
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 08:37:04 -0700 (PDT)
In-Reply-To: <1370406254-6341-3-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vxlan is removed with active vxlan's it would crash because
rtnl_link_unregister (which calls vxlan_dellink), was invoked
before unregister_pernet_device (which calls vxlan_stop).

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
See "vxlan: move IGMP join/leave to work queue" for the net-next
version of this

 drivers/net/vxlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3b1d2ee..5cc3b48 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1677,8 +1677,8 @@ module_init(vxlan_init_module);
 
 static void __exit vxlan_cleanup_module(void)
 {
-	rtnl_link_unregister(&vxlan_link_ops);
 	unregister_pernet_device(&vxlan_net_ops);
+	rtnl_link_unregister(&vxlan_link_ops);
 	rcu_barrier();
 }
 module_exit(vxlan_cleanup_module);
-- 
1.7.10.4
