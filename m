From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 3/11] ixgb: Change RDT write bump
 size to 4
Date: Thu, 28 Apr 2005 18:49:28 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281848230.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Disable RXO interrupt to decrease recovery time when system is overloaded with data

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-04-05 23:06:38.283932752 -0700
@@ -224,8 +224,8 @@ ixgb_irq_enable(struct ixgb_adapter *ada
 {
 	if(atomic_dec_and_test(&adapter->irq_sem)) {
 		IXGB_WRITE_REG(&adapter->hw, IMS,
-			   IXGB_INT_RXT0 | IXGB_INT_RXDMT0 | IXGB_INT_TXDW |
-			   IXGB_INT_RXO | IXGB_INT_LSC);
+			       IXGB_INT_RXT0 | IXGB_INT_RXDMT0 | IXGB_INT_TXDW |
+			       IXGB_INT_LSC);
 		IXGB_WRITE_FLUSH(&adapter->hw);
 	}
 }
