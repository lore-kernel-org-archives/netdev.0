From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 4/4] mISDN: DSP scheduling fix (version 2)
Date: Thu, 26 Apr 2012 08:54:48 +0200
Message-ID: <1335423288-30702-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56082 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab2DZG6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 02:58:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <isdn@linux-pingi.de>

dsp_spl_jiffies need to be the same datatype as jiffies (which is ulong).
If not, on 64 bit systems it will fallback to schedule the DSP every jiffie
tic as soon jiffies become > 2^32.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/mISDN/dsp.h     |    4 +++-
 drivers/isdn/mISDN/dsp_cmx.c |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp.h b/drivers/isdn/mISDN/dsp.h
index afe4173..e020957 100644
--- a/drivers/isdn/mISDN/dsp.h
+++ b/drivers/isdn/mISDN/dsp.h
@@ -76,7 +76,9 @@ extern u8 dsp_silence;
 #define MAX_SECONDS_JITTER_CHECK 5
 
 extern struct timer_list dsp_spl_tl;
-extern u32 dsp_spl_jiffies;
+
+/* the datatype need to match jiffies datatype */
+extern unsigned long dsp_spl_jiffies;
 
 /* the structure of conferences:
  *
diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index 0c104b9..3a3b3a5 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1624,7 +1624,7 @@ send_packet:
 
 static u32	jittercount; /* counter for jitter check */
 struct timer_list dsp_spl_tl;
-u32	dsp_spl_jiffies; /* calculate the next time to fire */
+unsigned long	dsp_spl_jiffies; /* calculate the next time to fire */
 static u16	dsp_count; /* last sample count */
 static int	dsp_count_valid; /* if we have last sample count */
 
-- 
1.7.3.4
