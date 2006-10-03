From: Ismail Donmez <ismail@pardus.org.tr>
Subject: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Tue, 3 Oct 2006 15:54:55 +0300
Message-ID: <200610031554.56353.ismail@pardus.org.tr>
References: <200609302223.47627.ismail@pardus.org.tr> <20061002111555.GB2936@ff.dom.local> <20061003102831.GA7778@kernel.dk>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_g2lIFKlgzt6agxc"
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:31682 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S932085AbWJCMyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 08:54:36 -0400
To: Jens Axboe <jens.axboe@oracle.com>
In-Reply-To: <20061003102831.GA7778@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_g2lIFKlgzt6agxc
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE 
changed behaviour so it returns true when the node is empty as expected. 
Hence Patrick McHardy's fix for sched_htb.c should be reverted.

Signed-off-by: Ismail Donmez <ismail@pardus.org.tr>

--Boundary-00=_g2lIFKlgzt6agxc
Content-Type: text/x-diff;
  charset="Iso-8859-1";
  name="rb.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="rb.diff"

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 6c058e3..1f1360e 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -391,7 +391,7 @@ static inline void htb_add_class_to_row(
 /* If this triggers, it is a bug in this code, but it need not be fatal */
 static void htb_safe_rb_erase(struct rb_node *rb, struct rb_root *root)
 {
-	if (!RB_EMPTY_NODE(rb)) {
+	if (RB_EMPTY_NODE(rb)) {
 		WARN_ON(1);
 	} else {
 		rb_erase(rb, root);

--Boundary-00=_g2lIFKlgzt6agxc--
