From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] deliver_skb cleanup
Date: Tue, 24 Aug 2004 11:35:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824113537.68c570fe@dell_ss3.pdx.osdl.net>
References: <20040824110711.3a1782d7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040824110711.3a1782d7@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Another cleanup in netif_receive_skb. Move rcu_read_lock up a little,
since it needs to be done in both branches anyway. Also whitespace fix.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-08-24 11:34:41 -07:00
+++ b/net/core/dev.c	2004-08-24 11:34:41 -07:00
@@ -1779,15 +1779,16 @@
 	skb->mac_len = skb->nh.raw - skb->mac.raw;
 
 	pt_prev = NULL;
+
+	rcu_read_lock();
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
-		rcu_read_lock();
 		goto ncls;
 	}
- #endif
+#endif
 
-	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev) 
