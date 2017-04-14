From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/9] netfilter: ctnetlink: using bit to represent the ct event
Date: Fri, 14 Apr 2017 02:26:44 +0200
Message-ID: <1492129611-29336-3-git-send-email-pablo@netfilter.org>
References: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35294 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754020AbdDNA1G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 20:27:06 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7841AE0442
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6A16EDA862
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 59247DA865
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:26:59 +0200 (CEST)
In-Reply-To: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Otherwise, creating a new conntrack via nfnetlink:
  # conntrack -I -p udp -s 1.1.1.1 -d 2.2.2.2 -t 10 --sport 10 --dport 20

will emit the wrong ct events(where UPDATE should be NEW):
  # conntrack -E
  [UPDATE] udp      17 10 src=1.1.1.1 dst=2.2.2.2 sport=10 dport=20
  [UNREPLIED] src=2.2.2.2 dst=1.1.1.1 sport=20 dport=10 mark=0

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 908d858034e4..59ee27deb9a0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1929,9 +1929,9 @@ static int ctnetlink_new_conntrack(struct net *net, struct sock *ctnl,
 
 			err = 0;
 			if (test_bit(IPS_EXPECTED_BIT, &ct->status))
-				events = IPCT_RELATED;
+				events = 1 << IPCT_RELATED;
 			else
-				events = IPCT_NEW;
+				events = 1 << IPCT_NEW;
 
 			if (cda[CTA_LABELS] &&
 			    ctnetlink_attach_labels(ct, cda) == 0)
-- 
2.1.4
