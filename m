From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/13] sfc: Fix byte order warning in self-test
Date: Sat, 1 Dec 2012 04:41:47 +0000
Message-ID: <1354336907.2640.41.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55606 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab2LAElu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:41:50 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add necessary cast when setting a bogus checksum.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/selftest.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index ce72ae4..f6651d3 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -373,7 +373,7 @@ static void efx_iterate_state(struct efx_nic *efx)
 	/* saddr set later and used as incrementing count */
 	payload->ip.daddr = htonl(INADDR_LOOPBACK);
 	payload->ip.ihl = 5;
-	payload->ip.check = htons(0xdead);
+	payload->ip.check = (__force __sum16) htons(0xdead);
 	payload->ip.tot_len = htons(sizeof(*payload) - sizeof(struct ethhdr));
 	payload->ip.version = IPVERSION;
 	payload->ip.protocol = IPPROTO_UDP;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
