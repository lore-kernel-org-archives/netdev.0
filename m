From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 13/17 linux-2.6.7-rc2] prism54: Align skb patch (resend)
Date: Sat, 5 Jun 2004 14:50:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051450.30316.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_WGcwAoFrpsImxIG"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_WGcwAoFrpsImxIG
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

* islpci_eth.c, islpci_dev.c : Align skb->data unconditonally after
  allocation. This would appear to improve RX rate



--Boundary-00=_WGcwAoFrpsImxIG
Content-Type: text/x-diff;
  charset="us-ascii";
  name="13-align-skb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="13-align-skb.patch"

diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.c	2004-06-05 14:06:30.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.c	2004-06-05 14:09:41.000000000 +0200
@@ -676,6 +676,7 @@
 			skb = NULL;
 			goto out_free;
 		}
+		skb_reserve(skb, (4 - (long) skb->data) & 0x03);
 		/* add the new allocated sk_buff to the buffer array */
 		priv->data_low_rx[counter] = skb;
 
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c	2004-06-05 14:09:07.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c	2004-06-05 14:09:41.000000000 +0200
@@ -440,6 +440,7 @@
 			DEBUG(SHOW_ERROR_MESSAGES, "Error allocating skb \n");
 			break;
 		}
+		skb_reserve(skb, (4 - (long) skb->data) & 0x03);
 		/* store the new skb structure pointer */
 		index = index % ISL38XX_CB_RX_QSIZE;
 		priv->data_low_rx[index] = skb;

--Boundary-00=_WGcwAoFrpsImxIG--
