From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 32/32] sfc: Update and improve kernel-doc for
 efx_mcdi_state & efx_mcdi_iface
Date: Thu, 22 Aug 2013 14:10:27 +0100
Message-ID: <1377177027.1703.41.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56571 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247Ab3HVNKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 09:10:30 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.h | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 0cb0d5a..69586e0 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -11,14 +11,14 @@
 #define EFX_MCDI_H
 
 /**
- * enum efx_mcdi_state
+ * enum efx_mcdi_state - MCDI request handling state
  * @MCDI_STATE_QUIESCENT: No pending MCDI requests. If the caller holds the
- *	mcdi_lock then they are able to move to MCDI_STATE_RUNNING
+ *	mcdi @iface_lock then they are able to move to %MCDI_STATE_RUNNING
  * @MCDI_STATE_RUNNING: There is an MCDI request pending. Only the thread that
  *	moved into this state is allowed to move out of it.
  * @MCDI_STATE_COMPLETED: An MCDI request has completed, but the owning thread
  *	has not yet consumed the result. For all other threads, equivalent to
- *	MCDI_STATE_RUNNING.
+ *	%MCDI_STATE_RUNNING.
  */
 enum efx_mcdi_state {
 	MCDI_STATE_QUIESCENT,
@@ -32,25 +32,23 @@ enum efx_mcdi_mode {
 };
 
 /**
- * struct efx_mcdi_iface
- * @state: Interface state. Waited for by mcdi_wq.
- * @wq: Wait queue for threads waiting for state != STATE_RUNNING
- * @iface_lock: Protects @credits, @seqno, @resprc, @resplen
+ * struct efx_mcdi_iface - MCDI protocol context
+ * @state: Request handling state. Waited for by @wq.
  * @mode: Poll for mcdi completion, or wait for an mcdi_event.
- *	Serialised by @lock
+ * @wq: Wait queue for threads waiting for @state != %MCDI_STATE_RUNNING
+ * @iface_lock: Serialises access to all the following fields
  * @seqno: The next sequence number to use for mcdi requests.
- *	Serialised by @lock
  * @credits: Number of spurious MCDI completion events allowed before we
- *	trigger a fatal error. Protected by @lock
+ *     trigger a fatal error
  * @resprc: Response error/success code (Linux numbering)
  * @resp_hdr_len: Response header length
  * @resp_data_len: Response data (SDU or error) length
  */
 struct efx_mcdi_iface {
 	atomic_t state;
+	enum efx_mcdi_mode mode;
 	wait_queue_head_t wq;
 	spinlock_t iface_lock;
-	enum efx_mcdi_mode mode;
 	unsigned int credits;
 	unsigned int seqno;
 	int resprc;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
