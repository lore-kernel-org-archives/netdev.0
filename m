From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/5] net: Properly define functions with no
 parameters
Date: Fri, 6 Jul 2012 23:44:21 +0100
Message-ID: <1341614661.2923.16.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341614561.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30717 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756532Ab2GFWoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 18:44:23 -0400
In-Reply-To: <1341614561.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defining a function as 'T foo()' is the deprecated K&R syntax, and is not
strictly equivalent to defining it as 'T foo(void)'.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/cris/eth_v10.c |    2 +-
 net/core/dev.c             |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 9c755db..f0c8bd5 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1008,7 +1008,7 @@ e100_send_mdio_bit(unsigned char bit)
 }
 
 static unsigned char
-e100_receive_mdio_bit()
+e100_receive_mdio_bit(void)
 {
 	unsigned char bit;
 	*R_NETWORK_MGM_CTRL = 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index 69f7a1a..9c21548 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1798,7 +1798,7 @@ EXPORT_SYMBOL(netif_set_real_num_rx_queues);
  * This routine should set an upper limit on the number of RSS queues
  * used by default by multiqueue devices.
  */
-int netif_get_num_default_rss_queues()
+int netif_get_num_default_rss_queues(void)
 {
 	return min_t(int, DEFAULT_MAX_NUM_RSS_QUEUES, num_online_cpus());
 }
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
