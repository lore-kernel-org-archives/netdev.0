From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] mpls_iptunnel: fix sparse warn: remove incorrect rcu_dereference
Date: Tue, 21 Jul 2015 22:49:00 -0700
Message-ID: <1437544140-38090-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35868 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbbGVFtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:49:06 -0400
Received: by pdjr16 with SMTP id r16so135283606pdj.3
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 22:49:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

fix for:
net/mpls/mpls_iptunnel.c:73:19: sparse: incompatible types in comparison
expression (different address spaces)

remove incorrect rcu_dereference possibly left over from
earlier revisions of the code.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/mpls_iptunnel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index eea096f..276f8c9 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -70,7 +70,7 @@ int mpls_output(struct sock *sk, struct sk_buff *skb)
 	skb_orphan(skb);
 
 	/* Find the output device */
-	out_dev = rcu_dereference(dst->dev);
+	out_dev = dst->dev;
 	if (!mpls_output_possible(out_dev) ||
 	    !lwtstate || skb_warn_if_lro(skb))
 		goto drop;
-- 
1.7.10.4
