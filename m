From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 14/21] net: hostap: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:42 +0200
Message-ID: <1439886649-24166-15-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
 <1439886649-24166-8-git-send-email-phil@nwl.cc>
 <1439886649-24166-9-git-send-email-phil@nwl.cc>
 <1439886649-24166-10-git-send-email-phil@nwl.cc>
 <1439886649-24166-11-git-send-email-phil@nwl.cc>
 <1439886649-24166-12-git-send-email-phil@nwl.cc>
 <1439886649-24166-13-git-send-email-phil@nwl.cc>
 <1439886649-24166-14-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net, Jouni Malinen <j@w1.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39336 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108AbbHRIa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:56 -0400
In-Reply-To: <1439886649-24166-14-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Jouni Malinen <j@w1.fi>
---
 drivers/net/wireless/hostap/hostap_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 01de1a3..80d4228 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -865,7 +865,7 @@ void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 
 	switch(type) {
 	case HOSTAP_INTERFACE_AP:
-		dev->tx_queue_len = 0;	/* use main radio device queue */
+		dev->priv_flags |= IFF_NO_QUEUE;	/* use main radio device queue */
 		dev->netdev_ops = &hostap_mgmt_netdev_ops;
 		dev->type = ARPHRD_IEEE80211;
 		dev->header_ops = &hostap_80211_ops;
@@ -874,7 +874,7 @@ void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 		dev->netdev_ops = &hostap_master_ops;
 		break;
 	default:
-		dev->tx_queue_len = 0;	/* use main radio device queue */
+		dev->priv_flags |= IFF_NO_QUEUE;	/* use main radio device queue */
 		dev->netdev_ops = &hostap_netdev_ops;
 	}
 
-- 
2.1.2
