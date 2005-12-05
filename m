From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH linux-2.6.15-rc5] sk98lin: rx checksum offset not set
Date: Mon, 5 Dec 2005 11:00:40 -0800
Message-ID: <20051205110040.47adf428@localhost.localdomain>
References: <Pine.LNX.4.64.0512032155290.3099@g5.osdl.org>
	<20051204234320.GA7478@linuxtv.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Stezenbach <js@linuxtv.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751419AbVLETAz@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20051204234320.GA7478@linuxtv.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The checksum offsets for receive offload were not being set correctly.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


Index: linux-2.6/drivers/net/sk98lin/skge.c
===================================================================
--- linux-2.6.orig/drivers/net/sk98lin/skge.c
+++ linux-2.6/drivers/net/sk98lin/skge.c
@@ -818,7 +818,7 @@ uintptr_t VNextDescr;	/* the virtual bus
 		/* set the pointers right */
 		pDescr->VNextRxd = VNextDescr & 0xffffffffULL;
 		pDescr->pNextRxd = pNextDescr;
-		pDescr->TcpSumStarts = 0;
+		if (!IsTx) pDescr->TcpSumStarts = ETH_HLEN << 16 | ETH_HLEN;
 
 		/* advance one step */
 		pPrevDescr = pDescr;
@@ -2169,7 +2169,7 @@ rx_start:	
 		} /* frame > SK_COPY_TRESHOLD */
 
 #ifdef USE_SK_RX_CHECKSUM
-		pMsg->csum = pRxd->TcpSums;
+		pMsg->csum = pRxd->TcpSums & 0xffff;
 		pMsg->ip_summed = CHECKSUM_HW;
 #else
 		pMsg->ip_summed = CHECKSUM_NONE;
