From: DataCom - Abreu <abreu@datacom-telematica.com.br>
Subject: 8139too interframe gap
Date: Thu, 3 Feb 2005 14:51:10 -0200
Message-ID: <20050203145110.06fa5ca6.abreu@datacom-telematica.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

The driver 8139too configures interframe gap with the shortest possible 
interval. This behaviour was commited by Jeff on version 0.9.4.1. From 
changelog:

* Do not set Interfame Gap (IFG) bits in TxConfig

The chip spec, though, says that these bits must be set in order to 
conform to 802.3. There is a comment on the code that says exactly the 
opposite. I would like to know why the configuration is set this way.

I have a problem where an external device inserts VLAN tags in frames, 
thus reducing the gap more yet. After that, too close frames (except the
 
first one) are not recognized by a switch.

I have set these bits and my problem disappears. My patch follows:


--- linux-2.6.10/drivers/net/8139too.c	2004-12-24 19:33:47.000000000 -0200
+++ linux-2.6.10-mod/drivers/net/8139too.c	2005-02-03 13:47:15.000000000 -0200
@@ -391,7 +391,7 @@
 /* Bits in TxConfig. */
 enum tx_config_bits {
 	TxIFG1 = (1 << 25),	/* Interframe Gap Time */
-	TxIFG0 = (1 << 24),	/* Enabling these bits violates IEEE 802.3 */
+	TxIFG0 = (1 << 24),	/* Disabling any of these bits violates IEEE 802.3 */
 	TxLoopBack = (1 << 18) | (1 << 17), /* enable loopback test mode */
 	TxCRC = (1 << 16),	/* DISABLE appending CRC to end of Tx packets */
 	TxClearAbt = (1 << 0),	/* Clear abort (WO) */
@@ -723,7 +723,7 @@
 #endif
 
 static const unsigned int rtl8139_tx_config =
-	(TX_DMA_BURST << TxDMAShift) | (TX_RETRY << TxRetryShift);
+	TxIFG1 | TxIFG0 | (TX_DMA_BURST << TxDMAShift) | (TX_RETRY << TxRetryShift);
 
 static void __rtl8139_cleanup_dev (struct net_device *dev)
 {



Thanks.

Marcelo Abreu
