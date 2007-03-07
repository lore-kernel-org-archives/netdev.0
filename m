From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [ATM] ENI: Convert to struct timeval to ktime_t.
Date: Wed, 07 Mar 2007 11:31:39 +0900 (JST)
Message-ID: <20070307.113139.07471835.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34378 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161221AbXCGCbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 21:31:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 8fccf01..0d3a38b 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -536,7 +536,7 @@ static int rx_aal0(struct atm_vcc *vcc)
 		return 0;
 	}
 	skb_put(skb,length);
-	skb_set_timestamp(skb, &eni_vcc->timestamp);
+	skb->tstamp = eni_vcc->timestamp;
 	DPRINTK("got len %ld\n",length);
 	if (do_rx_dma(vcc,skb,1,length >> 2,length >> 2)) return 1;
 	eni_vcc->rxing++;
@@ -701,7 +701,7 @@ static void get_service(struct atm_dev *dev)
 			DPRINTK("Grr, servicing VCC %ld twice\n",vci);
 			continue;
 		}
-		do_gettimeofday(&ENI_VCC(vcc)->timestamp);
+		ENI_VCC(vcc)->timestamp = ktime_get_real();
 		ENI_VCC(vcc)->next = NULL;
 		if (vcc->qos.rxtp.traffic_class == ATM_CBR) {
 			if (eni_dev->fast)
diff --git a/drivers/atm/eni.h b/drivers/atm/eni.h
index 385090c..d04fefb 100644
--- a/drivers/atm/eni.h
+++ b/drivers/atm/eni.h
@@ -59,7 +59,7 @@ struct eni_vcc {
 	int rxing;			/* number of pending PDUs */
 	int servicing;			/* number of waiting VCs (0 or 1) */
 	int txing;			/* number of pending TX bytes */
-	struct timeval timestamp;	/* for RX timing */
+	ktime_t timestamp;		/* for RX timing */
 	struct atm_vcc *next;		/* next pending RX */
 	struct sk_buff *last;		/* last PDU being DMAed (used to carry
 					   discard information) */

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
