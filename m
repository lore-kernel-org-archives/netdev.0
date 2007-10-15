From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: [PATCH] r8169 Fix hang in rtl8169_down (NAPI)
Date: Mon, 15 Oct 2007 22:25:46 +0200
Message-ID: <20071015202546.GA4060@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-43.synserver.de ([217.119.50.43]:1038 "HELO
	smtp-out-43.synserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756616AbXJOUmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 16:42:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit bea3348eef27e6044b6161fd04c3152215f96411 :
[NET]: Make NAPI polling independent of struct net_device objects.
causes my machine to hang on shutdown. The following patch fixes the
problem for me.

Signed-off-by: Markus Trippelsdorf <markus@trippelsdorf.de>


diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 419c00c..2cddbf8 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2888,10 +2888,12 @@ core_down:
 
 	synchronize_irq(dev->irq);
 
+#ifdef CONFIG_R8169_NAPI
 	if (!poll_locked) {
 		napi_disable(&tp->napi);
 		poll_locked++;
 	}
+#endif
 
 	/* Give a racing hard_start_xmit a few cycles to complete. */
 	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */

-- 
Markus
