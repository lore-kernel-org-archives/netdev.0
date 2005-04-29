From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 2/11] ixgb: Do not set the RS bit on
 context descriptors
Date: Thu, 28 Apr 2005 18:46:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281845540.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't set the RS bit on context descriptors, causes un-necessary bus activity 

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-04-05 23:06:38.283932752 -0700
@@ -1209,9 +1209,9 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 						| IXGB_CONTEXT_DESC_CMD_TSE
 						| IXGB_CONTEXT_DESC_CMD_IP
 						| IXGB_CONTEXT_DESC_CMD_TCP
-						| IXGB_CONTEXT_DESC_CMD_RS
 						| IXGB_CONTEXT_DESC_CMD_IDE
 						| (skb->len - (hdr_len)));
+
 
 		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
@@ -1246,9 +1246,8 @@ ixgb_tx_csum(struct ixgb_adapter *adapte
 		context_desc->hdr_len = 0;
 		context_desc->mss = 0;
 		context_desc->cmd_type_len =
-			cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
-					| IXGB_TX_DESC_CMD_RS 
-					| IXGB_TX_DESC_CMD_IDE);
+			cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
+				    | IXGB_TX_DESC_CMD_IDE);
 
 		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
