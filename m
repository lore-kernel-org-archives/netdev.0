From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] ssb: sprom: replace strict_strtoul() with kstrtoul()
Date: Sat, 01 Jun 2013 16:35:23 +0900
Message-ID: <001601ce5e9a$93bc9fb0$bb35df10$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"'David S. Miller'" <davem@davemloft.net>
To: 'Michael Buesch' <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:14245 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab3FAHfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 03:35:25 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MNP004XPEEZ12D0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Sat, 01 Jun 2013 16:35:24 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The usage of strict_strtoul() is not preferred, because
strict_strtoul() is obsolete. Thus, kstrtoul() should be
used.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/ssb/sprom.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/ssb/sprom.c b/drivers/ssb/sprom.c
index a3b2364..e753fbe 100644
--- a/drivers/ssb/sprom.c
+++ b/drivers/ssb/sprom.c
@@ -54,7 +54,7 @@ static int hex2sprom(u16 *sprom, const char *dump, size_t len,
 	while (cnt < sprom_size_words) {
 		memcpy(tmp, dump, 4);
 		dump += 4;
-		err = strict_strtoul(tmp, 16, &parsed);
+		err = kstrtoul(tmp, 16, &parsed);
 		if (err)
 			return err;
 		sprom[cnt++] = swab16((u16)parsed);
-- 
1.7.10.4
