From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH] test_bpf: fix the dummy skb after dissector changes
Date: Mon, 12 Sep 2016 13:04:57 +0100
Message-ID: <1473681897-32260-1-git-send-email-jakub.kicinski@netronome.com>
Cc: <netdev@vger.kernel.org>, Hadar Hen Zion <hadarh@mellanox.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34966 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754615AbcILMIl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 08:08:41 -0400
Received: by mail-wm0-f48.google.com with SMTP id a6so50317084wmc.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 05:08:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan
info from skb->vlan_tci") made flow dissector look at vlan_proto
when vlan is present.  Since test_bpf sets skb->vlan_tci to ~0
(including VLAN_TAG_PRESENT) we have to populate skb->vlan_proto.

Fixes false negative on test #24:
test_bpf: #24 LD_PAYLOAD_OFF jited:0 175 ret 0 != 42 FAIL (1 times)

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
 lib/test_bpf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 93f45011a59d..94346b4d8984 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -5485,6 +5485,7 @@ static struct sk_buff *populate_skb(char *buf, int size)
 	skb->hash = SKB_HASH;
 	skb->queue_mapping = SKB_QUEUE_MAP;
 	skb->vlan_tci = SKB_VLAN_TCI;
+	skb->vlan_proto = htons(ETH_P_IP);
 	skb->dev = &dev;
 	skb->dev->ifindex = SKB_DEV_IFINDEX;
 	skb->dev->type = SKB_DEV_TYPE;
-- 
1.9.1
