From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v2 5/6] net-PPP: Delete an unnecessary assignment in mppe_alloc()
Date: Thu, 04 Dec 2014 23:18:41 +0100
Message-ID: <5480DDC1.6040101@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.sourceforge.net> <547B4886.4080406@users.sourceforge.net> <547B
 496E.604@users.sourceforge.net> <547C5CBC.6060607@cogentembedded.com> <547C82A6.2030808@users.sourceforge.net> <547CA157.1080401@cogentembedded.com> <5480DA32.8000201@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <5480DA32.8000201@users.sourceforge.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 Dec 2014 22:33:34 +0100

The data structure element "arc4" was assigned a null pointer by the
mppe_alloc() function if a previous function call "crypto_alloc_blkcipher"
failed. This assignment became unnecessary with previous source
code adjustments.

Let us delete it from the affected implementation because the element "arc4"
will not be accessible outside the function after the detected
allocation failure.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ppp/ppp_mppe.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index c82198f..b7db4b1 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -204,10 +204,8 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 
 
 	state->arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(state->arc4)) {
-		state->arc4 = NULL;
+	if (IS_ERR(state->arc4))
 		goto out_free;
-	}
 
 	state->sha1 = crypto_alloc_hash("sha1", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(state->sha1)) {
-- 
2.1.3

