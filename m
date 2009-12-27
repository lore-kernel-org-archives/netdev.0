From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] atarilance: timeout ignored in lance_open()
Date: Sun, 27 Dec 2009 14:28:47 +0100
Message-ID: <4B37610F.8050401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752073AbZL0N0A@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With `while (--limit > 0)' i reaches 0 after the loop, so upon timeout the
error was not returned.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 8ce58c4..2aed2b3 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -2844,7 +2844,7 @@ static int tcam_wait_bit(struct niu *np, u64 bit)
 			break;
 		udelay(1);
 	}
-	if (limit < 0)
+	if (limit <= 0)
 		return -ENODEV;
 
 	return 0;
