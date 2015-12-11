From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 6/8] qeth: initialize net_device with carrier off
Date: Fri, 11 Dec 2015 12:27:55 +0100
Message-ID: <1449833277-69012-7-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1449833277-69012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:48552 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115AbbLKL2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 06:28:07 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 11 Dec 2015 11:28:05 -0000
In-Reply-To: <1449833277-69012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/sys/class/net/<interface>/operstate for an active qeth network
interface offen shows "unknown", which translates to "state UNKNOWN
in output of "ip link show". It is caused by a missing initialization
of the __LINK_STATE_NOCARRIER bit in the net_device state field.
This patch adds a netif_carrier_off() invocation when creating the
net_device for a qeth device.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Acked-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Reference-ID: Bugzilla 133209
---
 drivers/s390/net/qeth_l2_main.c | 1 +
 drivers/s390/net/qeth_l3_main.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 8f1b091..80b1979 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1126,6 +1126,7 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	qeth_l2_request_initial_mac(card);
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	netif_napi_add(card->dev, &card->napi, qeth_l2_poll, QETH_NAPI_WEIGHT);
+	netif_carrier_off(card->dev);
 	return register_netdev(card->dev);
 }
 
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index e2eb88c..10d9d3e 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3199,6 +3199,7 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	netif_napi_add(card->dev, &card->napi, qeth_l3_poll, QETH_NAPI_WEIGHT);
+	netif_carrier_off(card->dev);
 	return register_netdev(card->dev);
 }
 
-- 
2.3.9
