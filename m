From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] vxlan: remove vni zero check and drop for COLLECT_METADATA
Date: Fri, 10 Feb 2017 21:38:36 -0800
Message-ID: <1486791516-10285-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, joe@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36830 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdBKFi7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 00:38:59 -0500
Received: by mail-pg0-f49.google.com with SMTP id v184so16460442pgv.3
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 21:38:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch drops the vni zero check for COLLECT_METADATA mode.
It is not really needed, vni zero is a valid vni.

Fixes: 3ad7a4b141eb ("vxlan: support fdb and learning in COLLECT_METADATA mode"
Reported-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2374a75..4e27c5b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1333,9 +1333,6 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 
 	vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
 
-	if ((vs->flags & VXLAN_F_COLLECT_METADATA) && !vni)
-		goto drop;
-
 	vxlan = vxlan_vs_find_vni(vs, vni);
 	if (!vxlan)
 		goto drop;
-- 
1.7.10.4
