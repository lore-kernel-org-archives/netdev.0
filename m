From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 1/8] phc: Add a method for obtaining the device index.
Date: Sat, 17 Mar 2012 13:12:27 +0100
Message-ID: <1c74bab66cd1b5a03ac72435398637b8a887ee58.1331983687.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:48091 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030660Ab2CQMMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 08:12:45 -0400
Received: by wibhj6 with SMTP id hj6so1964362wib.1
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 05:12:44 -0700 (PDT)
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds a method that MAC drivers may call in order to find out
the device number of their associated PTP Hardware Clock.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_clock.c          |    6 ++++++
 include/linux/ptp_clock_kernel.h |    9 +++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index f519a13..1e528b5 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -304,6 +304,12 @@ void ptp_clock_event(struct ptp_clock *ptp, struct ptp_clock_event *event)
 }
 EXPORT_SYMBOL(ptp_clock_event);
 
+int ptp_clock_index(struct ptp_clock *ptp)
+{
+	return ptp->index;
+}
+EXPORT_SYMBOL(ptp_clock_index);
+
 /* module operations */
 
 static void __exit ptp_exit(void)
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index dd2e44f..58008a2 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -136,4 +136,13 @@ struct ptp_clock_event {
 extern void ptp_clock_event(struct ptp_clock *ptp,
 			    struct ptp_clock_event *event);
 
+/**
+ * ptp_clock_index() - obtain the device index of a PTP clock
+ *
+ * @ptp:    The clock obtained from ptp_clock_register().
+ * @event:  Message structure describing the event.
+ */
+
+extern int ptp_clock_index(struct ptp_clock *ptp);
+
 #endif
-- 
1.7.2.5
