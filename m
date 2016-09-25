From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/53] netfilter: ftp: Remove the useless dlen==0 condition check in find_pattern
Date: Mon, 26 Sep 2016 01:06:15 +0200
Message-ID: <1474844823-2026-6-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54542 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941161AbcIYXHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:25 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4D289B6C78
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3964BDA815
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 30A1CDA847
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:21 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The caller function "help" has already make sure the datalen could not be zero
before invoke find_pattern as a parameter by the following codes

        if (dataoff >= skb->len) {
                pr_debug("ftp: dataoff(%u) >= skblen(%u)\n", dataoff,
                         skb->len);
                return NF_ACCEPT;
        }
        datalen = skb->len - dataoff;

And the latter codes "ends_in_nl = (fb_ptr[datalen - 1] == '\n');" use datalen
directly without checking if it is zero.

So it is unneccessary to check it in find_pattern too.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_ftp.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index b6934b5edf7a..d49a2d410813 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -301,8 +301,6 @@ static int find_pattern(const char *data, size_t dlen,
 	size_t i = plen;
 
 	pr_debug("find_pattern `%s': dlen = %Zu\n", pattern, dlen);
-	if (dlen == 0)
-		return 0;
 
 	if (dlen <= plen) {
 		/* Short packet: try for partial? */
-- 
2.1.4
