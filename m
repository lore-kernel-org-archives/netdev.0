From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: cls_basic: fix memory leak in basic_destroy
Date: Fri, 30 Mar 2007 19:02:53 +0200
Message-ID: <460D42BD.6020500@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030702070307020300060608"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43379 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbXC3RDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 13:03:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030702070307020300060608
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------030702070307020300060608
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: cls_basic: fix memory leak in basic_destroy

tp->root is not freed on destruction.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b3df7f810c71b213224c105283c01e57ba7ed46a
tree 7f49d1edbc955609e369317a5a76100c87082377
parent 167c6a396949ee921bf70cbe58529f8e4dd4398d
author Patrick McHardy <kaber@trash.net> Fri, 30 Mar 2007 15:46:00 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 30 Mar 2007 15:46:00 +0200

 net/sched/cls_basic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index e76803c..c885412 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -110,6 +110,7 @@ static void basic_destroy(struct tcf_proto *tp)
 		list_del(&f->link);
 		basic_delete_filter(tp, f);
 	}
+	kfree(head);
 }
 
 static int basic_delete(struct tcf_proto *tp, unsigned long arg)

--------------030702070307020300060608--
