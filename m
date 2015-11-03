From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] irda: Delete an unnecessary check before the function call
 "irlmp_unregister_service"
Date: Tue, 3 Nov 2015 18:30:58 +0100
Message-ID: <5638EF52.7030300@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:53233 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932186AbbKCRbs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 12:31:48 -0500
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 3 Nov 2015 18:18:37 +0100

The irlmp_unregister_service() function tests whether its argument is NULL
and then returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/irda/af_irda.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index fae6822..e6aa48b 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2123,8 +2123,7 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 		}
 
 		/* Unregister any old registration */
-		if (self->skey)
-			irlmp_unregister_service(self->skey);
+		irlmp_unregister_service(self->skey);
 
 		self->skey = irlmp_register_service((__u16) opt);
 		break;
-- 
2.6.2
