From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/6) bridge: receive path optimization
Date: Thu, 26 May 2005 11:04:25 -0700
Message-ID: <20050526110425.27590eb8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============99615559241519969=="
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: "David S. Miller" <davem@davemloft.net>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============99615559241519969==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

This improves the bridge local receive path by avoiding going
through another softirq.  The bridge receive path is already being called 
from a netif_receive_skb() there is no point in going through another
receiveq round trip. 

Recursion is limited because bridge can never be a port of a bridge
so handle_bridge() always returns.

Index: bridge/net/bridge/br_input.c
===================================================================
--- bridge.orig/net/bridge/br_input.c
+++ bridge/net/bridge/br_input.c
@@ -26,7 +26,7 @@ static int br_pass_frame_up_finish(struc
 #ifdef CONFIG_NETFILTER_DEBUG
 	skb->nf_debug = 0;
 #endif
-	netif_rx(skb);
+	netif_receive_skb(skb);
 
 	return 0;
 }

--===============99615559241519969==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============99615559241519969==--
