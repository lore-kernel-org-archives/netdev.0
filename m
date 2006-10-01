From: Ismail Donmez <ismail@pardus.org.tr>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Sun, 1 Oct 2006 09:14:50 +0300
Message-ID: <200610010914.51623.ismail@pardus.org.tr>
References: <200609302223.47627.ismail@pardus.org.tr> <20061001015251.GA3795@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_bz1HFBIODmDW+ST"
Cc: axboe@suse.de, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:63428 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S1752026AbWJAGO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 02:14:27 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20061001015251.GA3795@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_bz1HFBIODmDW+ST
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sunday 01 October 2006 04:52, Herbert Xu wrote:
> On Sat, Sep 30, 2006 at 10:23:46PM +0300, Ismail Donmez wrote:
> > With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE
> > changed behaviour so it returns false when the node is empty as expected.
> > Hence Herbert's fix for sched_htb.c should be reverted.
>
> I've fixed sched_htb.c? That's news to me :)
>
> I fully agree with your patch though.

Oh it was Patrick McHardy <kaber@trash.net>, sorry. Patch again with a 
Signed-off line too this time.

Hi,

With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE 
changed behaviour so it returns false when the node is empty as expected. 
Hence Patrick McHardy's fix for sched_htb.c should be reverted.

[1] 
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=10fd48f2376db52f08bf0420d2c4f580e39269e1;hp=9817064b68fef7e4580c6df1ea597e106b9ff88b

Signed-off-by: Ismail Donmez <ismail@pardus.org.tr>

Regards,
ismail

--Boundary-00=_bz1HFBIODmDW+ST
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

--Boundary-00=_bz1HFBIODmDW+ST--
