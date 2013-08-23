From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH v2 1/4] jme: lower NAPI weight
Date: Fri, 23 Aug 2013 15:40:53 +0200
Message-ID: <52176665.2030507@redhat.com>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com> <1377103771-1590-2-git-send-email-mschmidt@redhat.com> <521503B6.4010105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755441Ab3HWNlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 09:41:02 -0400
In-Reply-To: <521503B6.4010105@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 82dc3c63 ("net: introduce NAPI_POLL_WEIGHT")
netif_napi_add() produces an error message if a NAPI poll weight
greater than 64 is requested.

jme requests a quarter of the rx ring size as the NAPI weight.
jme's rx ring size is 1 << 9 = 512.

Use the standard NAPI weight.

v2: proper reference to the related commit

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/jme.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 7fbe6ab..23de82a 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3069,7 +3069,7 @@ jme_init_one(struct pci_dev *pdev,
 		jwrite32(jme, JME_APMC, apmc);
 	}
 
-	NETIF_NAPI_SET(netdev, &jme->napi, jme_poll, jme->rx_ring_size >> 2)
+	NETIF_NAPI_SET(netdev, &jme->napi, jme_poll, NAPI_POLL_WEIGHT)
 
 	spin_lock_init(&jme->phy_lock);
 	spin_lock_init(&jme->macaddr_lock);
-- 
1.8.3.1
