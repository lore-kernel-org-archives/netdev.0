From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH 1/3] net/sched: act_ife: Unexport ife_tlv_meta_encode
Date: Wed,  1 Feb 2017 15:30:01 +0200
Message-ID: <1485955803-65065-2-git-send-email-yotamg@mellanox.com>
References: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        mrv@mojatatu.com, eladr@mellanox.com, jiri@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41037 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751289AbdBAN1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 08:27:40 -0500
In-Reply-To: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the function ife_tlv_meta_encode is not used by any other module,
unexport it and make it static for the act_ife module.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 include/net/tc_act/tc_ife.h | 2 --
 net/sched/act_ife.c         | 4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
index 9fd2bea0..f37e751 100644
--- a/include/net/tc_act/tc_ife.h
+++ b/include/net/tc_act/tc_ife.h
@@ -45,8 +45,6 @@ struct tcf_meta_ops {
 
 int ife_get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi);
 int ife_get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi);
-int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
-			const void *dval);
 int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval, gfp_t gfp);
 int ife_alloc_meta_u16(struct tcf_meta_info *mi, void *metaval, gfp_t gfp);
 int ife_check_meta_u32(u32 metaval, struct tcf_meta_info *mi);
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 921fb20..70148c1 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -48,7 +48,8 @@ static const struct nla_policy ife_policy[TCA_IFE_MAX + 1] = {
 
 /* Caller takes care of presenting data in network order
 */
-int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
+static int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
+			       const void *dval)
 {
 	u32 *tlv = (u32 *)(skbdata);
 	u16 totlen = nla_total_size(dlen);	/*alignment + hdr */
@@ -61,7 +62,6 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
 
 	return totlen;
 }
-EXPORT_SYMBOL_GPL(ife_tlv_meta_encode);
 
 int ife_encode_meta_u16(u16 metaval, void *skbdata, struct tcf_meta_info *mi)
 {
-- 
2.4.11
