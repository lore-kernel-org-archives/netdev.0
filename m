From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 01/26] phc: Add a method for obtaining the device index.
Date: Wed,  4 Apr 2012 10:59:16 +0200
Message-ID: <c80e9d0be719eccf7044d3fe4fbf1ef1d7907dc9.1333529506.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33404 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab2DDI74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 04:59:56 -0400
Received: by wibhq7 with SMTP id hq7so45831wib.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 01:59:55 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds a method that MAC drivers may call in order to find out
the device number of their associated PTP Hardware Clock.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_clock.c          |    6 ++++++
 include/linux/ptp_clock_kernel.h |    8 ++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

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
index dd2e44f..945704c 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -136,4 +136,12 @@ struct ptp_clock_event {
 extern void ptp_clock_event(struct ptp_clock *ptp,
 			    struct ptp_clock_event *event);
 
+/**
+ * ptp_clock_index() - obtain the device index of a PTP clock
+ *
+ * @ptp:    The clock obtained from ptp_clock_register().
+ */
+
+extern int ptp_clock_index(struct ptp_clock *ptp);
+
 #endif
-- 
1.7.2.5
