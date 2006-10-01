From: Ismail Donmez <ismail@pardus.org.tr>
Subject: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Sun, 1 Oct 2006 09:17:41 +0300
Message-ID: <200610010917.42003.ismail@pardus.org.tr>
References: <200609302223.47627.ismail@pardus.org.tr> <20061001015251.GA3795@gondor.apana.org.au> <200610010914.51623.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_G21HFZaV8vl+p/s"
Cc: axboe@suse.de, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:5029 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S1752033AbWJAGRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 02:17:22 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200610010914.51623.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_G21HFZaV8vl+p/s
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This time with correct description too, *sigh*

With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE 
changed behaviour so it returns true when the node is empty as expected. 
Hence Patrick McHardy's fix for sched_htb.c should be reverted.

[1] 
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=10fd48f2376db52f08bf0420d2c4f580e39269e1;hp=9817064b68fef7e4580c6df1ea597e106b9ff88b

Signed-off-by: Ismail Donmez <ismail@pardus.org.tr>

--Boundary-00=_G21HFZaV8vl+p/s
Content-Type: text/x-diff;
  charset="Iso-8859-15";
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

--Boundary-00=_G21HFZaV8vl+p/s--
