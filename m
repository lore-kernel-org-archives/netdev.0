From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 07/13] s390/qeth: don't convert return code twice
Date: Wed, 11 Jan 2017 12:55:54 +0100
Message-ID: <20170111115600.4524-8-ubraun@linux.vnet.ibm.com>
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

qeth_l2_send_groupmac() already translates the return code, so
calling qeth_setdel_makerc() a second time only produces garbage.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 3025f56..38fae10 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -210,8 +210,7 @@ static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
 				qeth_l2_send_setdelmac(card, mac->mac_addr,
 						IPA_CMD_SETVMAC));
 	} else {
-		rc = qeth_setdel_makerc(card,
-				qeth_l2_send_setgroupmac(card, mac->mac_addr));
+		rc = qeth_l2_send_setgroupmac(card, mac->mac_addr);
 	}
 	return rc;
 }
-- 
2.8.4
