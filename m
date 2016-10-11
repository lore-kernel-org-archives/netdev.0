From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Subject: [PATCH] drivers/ptp: Fix kernel memory disclosure
Date: Tue, 11 Oct 2016 15:02:47 +0200
Message-ID: <1476190967-38256-1-git-send-email-vlad@tsyrklevich.net>
Cc: richardcochran@gmail.com, Vlad Tsyrklevich <vlad@tsyrklevich.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36003 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751629AbcJKNDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 09:03:10 -0400
Received: by mail-lf0-f66.google.com with SMTP id b75so3627615lfg.3
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 06:03:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reserved field precise_offset->rsv is not cleared before being
copied to user space, leaking kernel stack memory. Clear the struct
before it's copied.

Signed-off-by: Vlad Tsyrklevich <vlad@tsyrklevich.net>

---
 drivers/ptp/ptp_chardev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index d637c93..58a97d4 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -193,6 +193,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		if (err)
 			break;
 
+		memset(&precise_offset, 0, sizeof(precise_offset));
 		ts = ktime_to_timespec64(xtstamp.device);
 		precise_offset.device.sec = ts.tv_sec;
 		precise_offset.device.nsec = ts.tv_nsec;
-- 
2.7.0
