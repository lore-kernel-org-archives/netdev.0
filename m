From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 52/52] sfc: Use CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS where appropriate
Date: Mon, 1 Sep 2008 12:50:28 +0100
Message-ID: <20080901115027.GS7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:47463 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759867AbYIALuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:50:32 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some buffers we use a starting offset of either NET_IP_ALIGN or 0
depending on whether we believe the architecture supports efficient
access to unaligned words.  There is now a config macro specifying
whether this is the case, so check that rather than checking for
specific architectures.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 +-
 drivers/net/sfc/tx.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 868ad1e..cdb11fa 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -474,7 +474,7 @@ enum nic_state {
  * This is the equivalent of NET_IP_ALIGN [which controls the alignment
  * of the skb->head for hardware DMA].
  */
-#if defined(__i386__) || defined(__x86_64__)
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 #define EFX_PAGE_IP_ALIGN 0
 #else
 #define EFX_PAGE_IP_ALIGN NET_IP_ALIGN
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index cdee7c2..da3e9ff 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -516,7 +516,7 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 /* Number of bytes inserted at the start of a TSO header buffer,
  * similar to NET_IP_ALIGN.
  */
-#if defined(__i386__) || defined(__x86_64__)
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 #define TSOH_OFFSET	0
 #else
 #define TSOH_OFFSET	NET_IP_ALIGN
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
