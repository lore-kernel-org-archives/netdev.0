From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] net: pack tc_cls_u32_knode struct slighter better
Date: Wed, 17 Feb 2016 14:59:30 -0800
Message-ID: <20160217225930.25736.17844.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.fastabend@gmail.com, jhs@mojatatu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35132 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965386AbcBQW7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 17:59:42 -0500
Received: by mail-pf0-f173.google.com with SMTP id c10so19840488pfc.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 14:59:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By packing the structure we can remove a few holes as Jamal
suggests.

before:

struct tc_cls_u32_knode {
	struct tcf_exts *          exts;                 /*     0     8 */
	u8                         fshift;               /*     8     1 */

	/* XXX 3 bytes hole, try to pack */

	u32                        handle;               /*    12     4 */
	u32                        val;                  /*    16     4 */
	u32                        mask;                 /*    20     4 */
	u32                        link_handle;          /*    24     4 */

	/* XXX 4 bytes hole, try to pack */

	struct tc_u32_sel *        sel;                  /*    32     8 */

	/* size: 40, cachelines: 1, members: 7 */
	/* sum members: 33, holes: 2, sum holes: 7 */
	/* last cacheline: 40 bytes */
};

after:

struct tc_cls_u32_knode {
	struct tcf_exts *          exts;                 /*     0     8 */
	struct tc_u32_sel *        sel;                  /*     8     8 */
	u32                        handle;               /*    16     4 */
	u32                        val;                  /*    20     4 */
	u32                        mask;                 /*    24     4 */
	u32                        link_handle;          /*    28     4 */
	u8                         fshift;               /*    32     1 */

	/* size: 40, cachelines: 1, members: 7 */
	/* padding: 7 */
	/* last cacheline: 40 bytes */
};

Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/pkt_cls.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 59789ca..2121df5 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -360,12 +360,12 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
 
 struct tc_cls_u32_knode {
 	struct tcf_exts *exts;
-	u8 fshift;
+	struct tc_u32_sel *sel;
 	u32 handle;
 	u32 val;
 	u32 mask;
 	u32 link_handle;
-	struct tc_u32_sel *sel;
+	u8 fshift;
 };
 
 struct tc_cls_u32_hnode {
