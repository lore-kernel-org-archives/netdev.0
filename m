From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v2 1/6] net-PPP: Replacement of a printk() call by pr_warn()
 in mppe_rekey()
Date: Thu, 04 Dec 2014 23:10:38 +0100
Message-ID: <5480DBDE.7040604@users.sourceforge.net>
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
Date: Thu, 4 Dec 2014 18:28:52 +0100

The mppe_rekey() function contained a few update candidates.
* Curly brackets were still used around a single function call "printk".
* Unwanted space characters

Let us improve these implementation details according to the current Linux
coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ppp/ppp_mppe.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 911b216..84b7bce 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -172,9 +172,8 @@ static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
 		setup_sg(sg_in, state->sha1_digest, state->keylen);
 		setup_sg(sg_out, state->session_key, state->keylen);
 		if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in,
-					     state->keylen) != 0) {
-    		    printk(KERN_WARNING "mppe_rekey: cipher_encrypt failed\n");
-		}
+					     state->keylen) != 0)
+			pr_warn("mppe_rekey: cipher_encrypt failed\n");
 	} else {
 		memcpy(state->session_key, state->sha1_digest, state->keylen);
 	}
-- 
2.1.3

