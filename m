From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: [PATCH 1/1] KS8695: update ksp->next_rx_desc_read at the end of rx
	loop
Date: Tue, 16 Mar 2010 16:42:06 +0100
Message-ID: <f69abfc31003160842r59c25bbdl2029d3f20e668e53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58674 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab0CPPmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 11:42:08 -0400
Received: by wyb38 with SMTP id 38so32135wyb.19
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 08:42:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KS8695: update ksp->next_rx_desc_read at the end of rx loop

There is no need to adjust the next rx descriptor after each packet,
so do it only once at the end of the routine.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Index: linux-2.6.34-rc1/drivers/net/arm/ks8695net.c
===================================================================
--- linux-2.6.34-rc1.orig/drivers/net/arm/ks8695net.c
+++ linux-2.6.34-rc1/drivers/net/arm/ks8695net.c
@@ -538,12 +538,13 @@ rx_finished:
 			 */
 			last_rx_processed = buff_n;
 			buff_n = (buff_n + 1) & MAX_RX_DESC_MASK;
-			/*And note which RX descriptor we last did */
-			if (likely(last_rx_processed != -1))
-				ksp->next_rx_desc_read =
-					(last_rx_processed + 1) &
-					MAX_RX_DESC_MASK;
 	}
+
+	/*And note which RX descriptor we last did */
+	if (likely(last_rx_processed != -1))
+		ksp->next_rx_desc_read =
+			(last_rx_processed + 1) & MAX_RX_DESC_MASK;
+
 	/* And refill the buffers */
 	ks8695_refill_rxbuffers(ksp);
