From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: [PATCH] arlan: use netstats in net_device structure
Date: Tue, 06 May 2008 14:44:08 +0300
Message-ID: <48204488.5030609@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030807070409040403080809"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030807070409040403080809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>

--------------030807070409040403080809
Content-Type: text/x-patch;
 name="arlan_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="arlan_netstats.patch"

diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index dbdfc9e..dec5e87 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -125,7 +125,7 @@ static inline int arlan_drop_tx(struct net_device *dev)
 {
 	struct arlan_private *priv = netdev_priv(dev);
 
-	priv->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	if (priv->Conf->tx_delay_ms)
 	{
 		priv->tx_done_delayed = jiffies + priv->Conf->tx_delay_ms * HZ / 1000 + 1;
@@ -1269,7 +1269,7 @@ static void arlan_tx_done_interrupt(struct net_device *dev, int status)
 		{
 			IFDEBUG(ARLAN_DEBUG_TX_CHAIN)
 				printk("arlan intr: transmit OK\n");
-			priv->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			priv->bad = 0;
 			priv->reset = 0;
 			priv->retransmissions = 0;
@@ -1496,7 +1496,7 @@ static void arlan_rx_interrupt(struct net_device *dev, u_char rxStatus, u_short
 			if (skb == NULL)
 			{
 				printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n", dev->name);
-				priv->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 			skb_reserve(skb, 2);
@@ -1536,14 +1536,14 @@ static void arlan_rx_interrupt(struct net_device *dev, u_char rxStatus, u_short
 				}
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			priv->stats.rx_packets++;
-			priv->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 		break;
 		
 		default:
 			printk(KERN_ERR "arlan intr: received unknown status\n");
-			priv->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 			break;
 	}
 	ARLAN_DEBUG_EXIT("arlan_rx_interrupt");
@@ -1719,23 +1719,23 @@ static struct net_device_stats *arlan_statistics(struct net_device *dev)
 
 	/* Update the statistics from the device registers. */
 
-	READSHM(priv->stats.collisions, arlan->numReTransmissions, u_int);
-	READSHM(priv->stats.rx_crc_errors, arlan->numCRCErrors, u_int);
-	READSHM(priv->stats.rx_dropped, arlan->numFramesDiscarded, u_int);
-	READSHM(priv->stats.rx_fifo_errors, arlan->numRXBufferOverflows, u_int);
-	READSHM(priv->stats.rx_frame_errors, arlan->numReceiveFramesLost, u_int);
-	READSHM(priv->stats.rx_over_errors, arlan->numRXOverruns, u_int);
-	READSHM(priv->stats.rx_packets, arlan->numDatagramsReceived, u_int);
-	READSHM(priv->stats.tx_aborted_errors, arlan->numAbortErrors, u_int);
-	READSHM(priv->stats.tx_carrier_errors, arlan->numStatusTimeouts, u_int);
-	READSHM(priv->stats.tx_dropped, arlan->numDatagramsDiscarded, u_int);
-	READSHM(priv->stats.tx_fifo_errors, arlan->numTXUnderruns, u_int);
-	READSHM(priv->stats.tx_packets, arlan->numDatagramsTransmitted, u_int);
-	READSHM(priv->stats.tx_window_errors, arlan->numHoldOffs, u_int);
+	READSHM(dev->stats.collisions, arlan->numReTransmissions, u_int);
+	READSHM(dev->stats.rx_crc_errors, arlan->numCRCErrors, u_int);
+	READSHM(dev->stats.rx_dropped, arlan->numFramesDiscarded, u_int);
+	READSHM(dev->stats.rx_fifo_errors, arlan->numRXBufferOverflows, u_int);
+	READSHM(dev->stats.rx_frame_errors, arlan->numReceiveFramesLost, u_int);
+	READSHM(dev->stats.rx_over_errors, arlan->numRXOverruns, u_int);
+	READSHM(dev->stats.rx_packets, arlan->numDatagramsReceived, u_int);
+	READSHM(dev->stats.tx_aborted_errors, arlan->numAbortErrors, u_int);
+	READSHM(dev->stats.tx_carrier_errors, arlan->numStatusTimeouts, u_int);
+	READSHM(dev->stats.tx_dropped, arlan->numDatagramsDiscarded, u_int);
+	READSHM(dev->stats.tx_fifo_errors, arlan->numTXUnderruns, u_int);
+	READSHM(dev->stats.tx_packets, arlan->numDatagramsTransmitted, u_int);
+	READSHM(dev->stats.tx_window_errors, arlan->numHoldOffs, u_int);
 
 	ARLAN_DEBUG_EXIT("arlan_statistics");
 
-	return &priv->stats;
+	return &dev->stats;
 }
 
 
diff --git a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
index 3ed1df7..fb3ad51 100644
--- a/drivers/net/wireless/arlan.h
+++ b/drivers/net/wireless/arlan.h
@@ -330,7 +330,6 @@ struct TxParam
 #define TX_RING_SIZE 2
 /* Information that need to be kept for each board. */
 struct arlan_private {
-      struct net_device_stats stats;
       struct arlan_shmem __iomem * card;
       struct arlan_shmem * conf;
 

--------------030807070409040403080809--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
