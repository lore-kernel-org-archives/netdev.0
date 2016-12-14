From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: vrf: Fix NAT within a VRF
Date: Wed, 14 Dec 2016 11:06:18 -0800
Message-ID: <1481742378-28165-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34161 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbcLNTG3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 14:06:29 -0500
Received: by mail-pf0-f173.google.com with SMTP id c4so4923440pfb.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 11:06:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Connection tracking with VRF is broken because the pass through the VRF
device drops the connection tracking info. Removing the call to nf_reset
allows DNAT and MASQUERADE to work across interfaces within a VRF.

Fixes: 73e20b761acf ("net: vrf: Add support for PREROUTING rules on vrf device")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 3bca24651dc0..015a1321c7dd 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -849,8 +849,6 @@ static struct sk_buff *vrf_rcv_nfhook(u8 pf, unsigned int hook,
 {
 	struct net *net = dev_net(dev);
 
-	nf_reset(skb);
-
 	if (NF_HOOK(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) < 0)
 		skb = NULL;    /* kfree_skb(skb) handled by nf code */
 
-- 
2.1.4
