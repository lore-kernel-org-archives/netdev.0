From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 13/26] e100: Convert e100 to use netdev_alloc_skb().
Date: Tue, 29 Aug 2006 09:44:43 -0700
Message-ID: <20060829164443.6872.7707.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:42762 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965087AbWH2Qga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:30 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index b42ad76..458af6a 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1759,7 +1759,7 @@ static inline void e100_start_receiver(s
 #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
 static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 {
-	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + NET_IP_ALIGN)))
+	if(!(rx->skb = netdev_alloc_skb(nic->netdev, RFD_BUF_LEN + NET_IP_ALIGN)))
 		return -ENOMEM;
 
 	/* Align, init, and map the RFD. */
@@ -2139,7 +2139,7 @@ static int e100_loopback_test(struct nic
 
 	e100_start_receiver(nic, NULL);
 
-	if(!(skb = dev_alloc_skb(ETH_DATA_LEN))) {
+	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
 		err = -ENOMEM;
 		goto err_loopback_none;
 	}



---
Auke Kok <auke-jan.h.kok@intel.com>
