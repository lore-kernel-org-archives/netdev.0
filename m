From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 2.6.21]: cls_tcindex: fix compatibility breakage
Date: Mon, 09 Apr 2007 18:30:42 +0200
Message-ID: <461A6A32.2040809@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070803040308050407030501"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39789 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966197AbXDIQas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 12:30:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070803040308050407030501
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix tcindex userspace compatibility breakage on big-endian.
Patch applies to current -git and -stable.


--------------070803040308050407030501
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: cls_tcindex: fix compatibility breakage

Userspace uses an integer for TCA_TCINDEX_SHIFT, the kernel was changed
to expect and use a u16 value in 2.6.11, which broke compatibility on
big endian machines. Change back to use int.

Reported by Ole Reinartz <ole.reinartz@gmx.de>

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 763d781919d5a69bea12c8f191486c562f16f515
tree 6dc589cde5689766059f32d451b65ff1f40509e0
parent 526a622afe930173cae35fe53948f380f0c04fef
author Patrick McHardy <kaber@trash.net> Mon, 09 Apr 2007 05:55:58 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 09 Apr 2007 05:55:58 +0200

 net/sched/cls_tcindex.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 040e2d2..7563fdc 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -245,9 +245,9 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 	}
 
 	if (tb[TCA_TCINDEX_SHIFT-1]) {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_SHIFT-1]) < sizeof(u16))
+		if (RTA_PAYLOAD(tb[TCA_TCINDEX_SHIFT-1]) < sizeof(int))
 			goto errout;
-		cp.shift = *(u16 *) RTA_DATA(tb[TCA_TCINDEX_SHIFT-1]);
+		cp.shift = *(int *) RTA_DATA(tb[TCA_TCINDEX_SHIFT-1]);
 	}
 
 	err = -EBUSY;

--------------070803040308050407030501--
