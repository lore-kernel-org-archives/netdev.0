From: Pablo Neira <pablo@eurodev.net>
Subject: [NETLINK] hlist initilization
Date: Fri, 24 Sep 2004 03:05:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415372F4.1010400@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060603070007000300000509"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060603070007000300000509
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Davem,

This patch adds proper initialization for hlist. It applies to 
af_netlink.c with the workqueue patch reverted.

Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>

regards,
Pablo

--------------060603070007000300000509
Content-Type: text/x-patch;
 name="hlist-initialize.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hlist-initialize.patch"

===== net/netlink/af_netlink.c 1.55 vs edited =====
--- 1.55/net/netlink/af_netlink.c	Thu Sep 23 20:27:46 2004
+++ edited/net/netlink/af_netlink.c	Sat Oct 23 19:09:17 2004
@@ -1191,6 +1191,10 @@
 static int __init netlink_proto_init(void)
 {
 	struct sk_buff *dummy_skb;
+	int i;
+
+	for(i=0; i<MAX_LINKS; i++)
+		INIT_HLIST_HEAD(&nl_table[i]);
 
 	if (sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb)) {
 		printk(KERN_CRIT "netlink_init: panic\n");

--------------060603070007000300000509--
