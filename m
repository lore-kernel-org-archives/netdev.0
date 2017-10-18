From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 05/13] s390/qeth: fix early exit from error path
Date: Wed, 18 Oct 2017 17:40:17 +0200
Message-ID: <20171018154025.73630-6-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40598 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751873AbdJRPkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:45 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdZEC000630
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:45 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp6squ75k-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:44 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:43 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the allocation of the addr buffer fails, we need to free
our refcount on the inetdevice before returning.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 270ac9515f6b..aadd384316a3 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1553,7 +1553,7 @@ static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
 
 	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
 	if (!addr)
-		return;
+		goto out;
 
 	spin_lock_bh(&card->ip_lock);
 
@@ -1567,6 +1567,7 @@ static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
 	spin_unlock_bh(&card->ip_lock);
 
 	kfree(addr);
+out:
 	in_dev_put(in_dev);
 }
 
@@ -1591,7 +1592,7 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
 
 	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
 	if (!addr)
-		return;
+		goto out;
 
 	spin_lock_bh(&card->ip_lock);
 
@@ -1606,6 +1607,7 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
 	spin_unlock_bh(&card->ip_lock);
 
 	kfree(addr);
+out:
 	in6_dev_put(in6_dev);
 #endif /* CONFIG_QETH_IPV6 */
 }
-- 
2.13.5
