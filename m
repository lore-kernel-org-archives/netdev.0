From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/2] lcs: fix compilation for !CONFIG_IP_MULTICAST
Date: Tue, 20 Jan 2009 17:14:32 +0100
Message-ID: <20090120161556.479681000@linux.vnet.ibm.com>
References: <20090120161431.149552000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jeff@garzik.org, netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:59808 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870AbZATQQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 11:16:02 -0500
Content-Disposition: inline; filename=604-lcs-multicast.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

drivers/s390/net/lcs.c: In function 'lcs_new_device':
drivers/s390/net/lcs.c:2179: error: implicit declaration of function 'lcs_set_multicast_list'

Reported-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/lcs.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2009-01-15 15:07:19.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2009-01-15 15:07:28.000000000 +0100
@@ -70,7 +70,9 @@ static char debug_buffer[255];
 static void lcs_tasklet(unsigned long);
 static void lcs_start_kernel_thread(struct work_struct *);
 static void lcs_get_frames_cb(struct lcs_channel *, struct lcs_buffer *);
+#ifdef CONFIG_IP_MULTICAST
 static int lcs_send_delipm(struct lcs_card *, struct lcs_ipm_list *);
+#endif /* CONFIG_IP_MULTICAST */
 static int lcs_recovery(void *ptr);
 
 /**
@@ -1285,6 +1287,8 @@ out:
 	lcs_clear_thread_running_bit(card, LCS_SET_MC_THREAD);
 	return 0;
 }
+#endif /* CONFIG_IP_MULTICAST */
+
 /**
  * function called by net device to
  * handle multicast address relevant things
@@ -1292,6 +1296,7 @@ out:
 static void
 lcs_set_multicast_list(struct net_device *dev)
 {
+#ifdef CONFIG_IP_MULTICAST
         struct lcs_card *card;
 
         LCS_DBF_TEXT(4, trace, "setmulti");
@@ -1299,9 +1304,8 @@ lcs_set_multicast_list(struct net_device
 
         if (!lcs_set_thread_start_bit(card, LCS_SET_MC_THREAD))
 		schedule_work(&card->kernel_thread_starter);
-}
-
 #endif /* CONFIG_IP_MULTICAST */
+}
 
 static long
 lcs_check_irb_error(struct ccw_device *cdev, struct irb *irb)

-- 
