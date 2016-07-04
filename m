From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/1] qeth: delete napi struct when removing a qeth device
Date: Mon,  4 Jul 2016 14:07:16 +0200
Message-ID: <1467634036-49548-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1467634036-49548-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	stable@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1467634036-49548-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A qeth_card contains a napi_struct linked to the net_device during
device probing. This struct must be deleted when removing the qeth
device, otherwise Panic on oops can occur when qeth devices are
repeatedly removed and added.

Fixes: a1c3ed4c9ca ("qeth: NAPI support for l2 and l3 discipline")
Cc: stable@vger.kernel.org # v2.6.37+
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Tested-by: Alexander Klein <ALKL@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 1 +
 drivers/s390/net/qeth_l3_main.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 80b1979..df036b8 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1051,6 +1051,7 @@ static void qeth_l2_remove_device(struct ccwgroup_device *cgdev)
 		qeth_l2_set_offline(cgdev);
 
 	if (card->dev) {
+		netif_napi_del(&card->napi);
 		unregister_netdev(card->dev);
 		card->dev = NULL;
 	}
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index ac54433..709b523 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3226,6 +3226,7 @@ static void qeth_l3_remove_device(struct ccwgroup_device *cgdev)
 		qeth_l3_set_offline(cgdev);
 
 	if (card->dev) {
+		netif_napi_del(&card->napi);
 		unregister_netdev(card->dev);
 		card->dev = NULL;
 	}
-- 
2.6.6
