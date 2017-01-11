From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/13] s390/qeth: Allow reading hsuid in state DOWN
Date: Wed, 11 Jan 2017 12:55:51 +0100
Message-ID: <20170111115600.4524-5-ubraun@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Accessing the current hsuid via card->options.hsuid is perfectly
fine, even when the card is DOWN.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_sys.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index 0e00a5c..3cd4d9f 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -250,9 +250,6 @@ static ssize_t qeth_l3_dev_hsuid_show(struct device *dev,
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		return -EPERM;
 
-	if (card->state == CARD_STATE_DOWN)
-		return -EPERM;
-
 	memcpy(tmp_hsuid, card->options.hsuid, sizeof(tmp_hsuid));
 	EBCASC(tmp_hsuid, 8);
 	return sprintf(buf, "%s\n", tmp_hsuid);
-- 
2.8.4
