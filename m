From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 2/2] sfc: Restore the effect of the rss_cpus module
 parameter
Date: Fri, 14 Jan 2011 14:25:40 +0000
Message-ID: <1295015140.5386.3.camel@bwh-desktop>
References: <1295014889.5386.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57990 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756855Ab1ANOZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 09:25:43 -0500
In-Reply-To: <1295014889.5386.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a4900ac ("sfc: Create multiple TX queues") accidentally
disabled the rss_cpus module parameter.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c2dc9a5..002bac7 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1153,6 +1153,9 @@ static int efx_wanted_channels(void)
 	int count;
 	int cpu;
 
+	if (rss_cpus)
+		return rss_cpus;
+
 	if (unlikely(!zalloc_cpumask_var(&core_mask, GFP_KERNEL))) {
 		printk(KERN_WARNING
 		       "sfc: RSS disabled due to allocation failure\n");
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

