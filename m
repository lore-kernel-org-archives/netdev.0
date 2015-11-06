From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] fjes: Delete an unnecessary check before the function call
 "vfree"
Date: Fri, 6 Nov 2015 09:39:23 +0100
Message-ID: <563C673B.1020605@users.sourceforge.net>
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
To: Taku Izumi <izumi.taku@jp.fujitsu.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 6 Nov 2015 09:30:29 +0100

The vfree() function performs also input parameter validation.
Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/fjes/fjes_hw.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 2d3848c..bb8b530 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -143,9 +143,7 @@ static int fjes_hw_alloc_epbuf(struct epbuf_handler *epbh)
 
 static void fjes_hw_free_epbuf(struct epbuf_handler *epbh)
 {
-	if (epbh->buffer)
-		vfree(epbh->buffer);
-
+	vfree(epbh->buffer);
 	epbh->buffer = NULL;
 	epbh->size = 0;
 
-- 
2.6.2
