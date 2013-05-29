From: nikolay@redhat.com
Subject: [PATCH] bonding: change igmp_retrans type from s8 to u8
Date: Wed, 29 May 2013 17:02:14 +0200
Message-ID: <1369839734-7131-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60533 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966771Ab3E2PFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 11:05:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

According to the bonding documentation and to the error messages the
resend_igmp should be between 0 and 255, but since the type of the
variable that counts is wrong, this is not the case.
We have igmp_retrans = resend_igmp when the work is started.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bonding.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2baec24..f989e15 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -225,7 +225,7 @@ struct bonding {
 	rwlock_t curr_slave_lock;
 	u8	 send_peer_notif;
 	s8	 setup_by_slave;
-	s8       igmp_retrans;
+	u8       igmp_retrans;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
 	char     proc_file_name[IFNAMSIZ];
-- 
1.8.1.4
