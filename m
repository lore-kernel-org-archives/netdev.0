From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/2] bonding: remove the redundant judgements for bond_option_queue_id_set()
Date: Wed, 12 Feb 2014 14:58:50 +0800
Message-ID: <1392188330-17208-3-git-send-email-dingtianhong@huawei.com>
References: <1392188330-17208-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:58136 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbaBLG70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 01:59:26 -0500
In-Reply-To: <1392188330-17208-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev_valid_name() will check the buffer length for input name, no need to
check it twice.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 11cb943..832d6e9 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1199,8 +1199,7 @@ int bond_option_queue_id_set(struct bonding *bond,
 		goto err_no_cmd;
 
 	/* Check buffer length, valid ifname and queue id */
-	if (strlen(newval->string) > IFNAMSIZ ||
-	    !dev_valid_name(newval->string) ||
+	if (!dev_valid_name(newval->string) ||
 	    qid > bond->dev->real_num_tx_queues)
 		goto err_no_cmd;
 
-- 
1.8.0
