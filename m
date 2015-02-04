From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] orinoco: Delete an unnecessary check before the function
 call "kfree"
Date: Wed, 04 Feb 2015 19:56:51 +0100
Message-ID: <54D26B73.1050804@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:57694 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161480AbbBDS45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 13:56:57 -0500
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 4 Feb 2015 19:53:11 +0100

The kfree() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/orinoco/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 38ec8d1..c410180 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -2342,7 +2342,7 @@ void free_orinocodev(struct orinoco_private *priv)
 	list_for_each_entry_safe(sd, sdtemp, &priv->scan_list, list) {
 		list_del(&sd->list);
 
-		if ((sd->len > 0) && sd->buf)
+		if (sd->len > 0)
 			kfree(sd->buf);
 		kfree(sd);
 	}
-- 
2.2.2
