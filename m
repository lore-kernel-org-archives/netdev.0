From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] isdnloop: Validate NUL-terminated strings from user.
Date: Wed, 02 Apr 2014 12:48:42 +0900
Message-ID: <533B889A.2060105@linux-ipv6.org>
References: <20140401.161838.1562296825577866979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vegard Nossum <vegard.nossum@oracle.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59605 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756116AbaDBDyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 23:54:00 -0400
In-Reply-To: <20140401.161838.1562296825577866979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return -EINVAL unless all of user-given strings are correctly
NUL-terminated.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/isdn/isdnloop/isdnloop.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index 02125e6..e1f8748 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -1070,6 +1070,12 @@ isdnloop_start(isdnloop_card *card, isdnloop_sdef *sdefp)
 		return -EBUSY;
 	if (copy_from_user((char *) &sdef, (char *) sdefp, sizeof(sdef)))
 		return -EFAULT;
+
+	for (i = 0; i < 3; i++) {
+		if (!memchr(sdef.num[i], 0, sizeof(sdef.num[i])))
+			return -EINVAL;
+	}
+
 	spin_lock_irqsave(&card->isdnloop_lock, flags);
 	switch (sdef.ptype) {
 	case ISDN_PTYPE_EURO:
-- 
1.7.9.5
