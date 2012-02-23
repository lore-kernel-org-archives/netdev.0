From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/5] sfc: Specify that the VFDI status page has
 page alignment and size
Date: Thu, 23 Feb 2012 17:40:14 +0000
Message-ID: <1330018814.2511.2.camel@bwh-desktop>
References: <1330018734.2511.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7232 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752207Ab2BWRkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 12:40:17 -0500
In-Reply-To: <1330018734.2511.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This requirement was meant to be implied in the name 'status page'.
One out-of-tree VF driver allocates a buffer using the structure size
and not a full page - hence the current odd specification - but in
practice that allocation will be padded and aligned to at least 4KB.
Therefore, we can specify this and have the option to extend the
structure up to 4KB without worrying about VF drivers using odd-shaped
buffers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/vfdi.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/vfdi.h b/drivers/net/ethernet/sfc/vfdi.h
index 656fa70..225557c 100644
--- a/drivers/net/ethernet/sfc/vfdi.h
+++ b/drivers/net/ethernet/sfc/vfdi.h
@@ -152,7 +152,8 @@ enum vfdi_op {
  *	all traffic at this receive queue.
  * @u.mac_filter.flags: MAC filter flags.
  * @u.set_status_page.dma_addr: Base address for the &struct vfdi_status.
- *	This address must be such that the structure fits within a page.
+ *	This address must be page-aligned and the PF may write up to a
+ *	whole page (allowing for extension of the structure).
  * @u.set_status_page.peer_page_count: Number of additional pages the VF
  *	has provided into which peer addresses may be DMAd.
  * @u.set_status_page.peer_page_addr: Array of DMA addresses of pages.
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
