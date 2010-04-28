From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/17] sfc: Clean up efx_nic::irq_zero_count
Date: Wed, 28 Apr 2010 20:30:00 +0100
Message-ID: <1272483000.2549.30.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12606 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab0D1TaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:30:03 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need for this to be unsigned long; make it unsigned int.
It does need a line in kernel-doc, so add that.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index bdea03c..d68331c 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -672,6 +672,7 @@ union efx_multicast_hash {
  *	This register is written with the SMP processor ID whenever an
  *	interrupt is handled.  It is used by efx_nic_test_interrupt()
  *	to verify that an interrupt has occurred.
+ * @irq_zero_count: Number of legacy IRQs seen with queue flags == 0
  * @fatal_irq_level: IRQ level (bit number) used for serious errors
  * @spi_flash: SPI flash device
  *	This field will be %NULL if no flash device is present (or for Siena).
@@ -756,7 +757,7 @@ struct efx_nic {
 
 	struct efx_buffer irq_status;
 	volatile signed int last_irq_cpu;
-	unsigned long irq_zero_count;
+	unsigned irq_zero_count;
 	unsigned fatal_irq_level;
 
 	struct efx_spi_device *spi_flash;
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

