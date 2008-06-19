From: Dmitry Baryshkov <dbaryshkov@gmail.com>
Subject: [PATCH] RFKILL: fix input layer initialisation
Date: Thu, 19 Jun 2008 15:28:41 +0400
Message-ID: <20080619112841.GA12051@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, IvDoorn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:17875 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbYFSL3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:29:01 -0400
Received: by fg-out-1718.google.com with SMTP id 19so362622fgg.17
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 04:29:00 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialise correctly last fields, so tasks can be actually executed

Also move rfkill-input initialisation to subsys level so that it's
available before generic drivers probing occurs.

Signed-off-by: Dmitry Baryshkov <dbaryshkov@gmail.com>
---
 net/rfkill/rfkill-input.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
index e4b051d..e4540fc 100644
--- a/net/rfkill/rfkill-input.c
+++ b/net/rfkill/rfkill-input.c
@@ -181,6 +181,11 @@ static struct input_handler rfkill_handler = {
 
 static int __init rfkill_handler_init(void)
 {
+	unsigned long last_run = jiffies - msecs_to_jiffies(500);
+	rfkill_wlan.last = last_run;
+	rfkill_bt.last = last_run;
+	rfkill_uwb.last = last_run;
+	rfkill_wimax.last = last_run;
 	return input_register_handler(&rfkill_handler);
 }
 
@@ -190,5 +195,5 @@ static void __exit rfkill_handler_exit(void)
 	flush_scheduled_work();
 }
 
-module_init(rfkill_handler_init);
+subsys_initcall(rfkill_handler_init);
 module_exit(rfkill_handler_exit);
-- 
1.5.5.3


-- 
With best wishes
Dmitry

