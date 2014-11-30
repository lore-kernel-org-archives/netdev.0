From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/3] net-PPP: Deletion of unnecessary checks before the function
 call "kfree"
Date: Sun, 30 Nov 2014 17:44:30 +0100
Message-ID: <547B496E.604@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <547B4886.4080406@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <547B4886.4080406@users.sourceforge.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 30 Nov 2014 17:02:07 +0100

The kfree() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ppp/ppp_mppe.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 911b216..7e44212 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -238,8 +238,7 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 	return (void *)state;
 
 	out_free:
-	    if (state->sha1_digest)
-		kfree(state->sha1_digest);
+	kfree(state->sha1_digest);
 	    if (state->sha1)
 		crypto_free_hash(state->sha1);
 	    if (state->arc4)
@@ -256,13 +255,12 @@ static void mppe_free(void *arg)
 {
 	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
 	if (state) {
-	    if (state->sha1_digest)
 		kfree(state->sha1_digest);
-	    if (state->sha1)
-		crypto_free_hash(state->sha1);
-	    if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
-	    kfree(state);
+		if (state->sha1)
+			crypto_free_hash(state->sha1);
+		if (state->arc4)
+			crypto_free_blkcipher(state->arc4);
+		kfree(state);
 	}
 }
 
-- 
2.1.3

