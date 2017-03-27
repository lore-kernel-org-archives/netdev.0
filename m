From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH v2] net: netfilter: Remove multiple assignment.
Date: Tue, 28 Mar 2017 04:03:27 +0530
Message-ID: <20170327223326.GA486@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35349 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbdC0Wdw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 18:33:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes multiple assignments to follow the kernel coding
style as also reported by checkpatch.pl.
Done using coccinelle.
@@
identifier i1,i2;
constant c;
@@
- i1=i2=c;
+ i1=c;
+ i2=i1;

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
changes in v2
 -Make the commit message more clear and appropriate.

 net/netfilter/nf_conntrack_proto_sctp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 33279aab583d..723386bcc2cb 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -346,7 +346,8 @@ static int sctp_packet(struct nf_conn *ct,
 		goto out;
 	}
 
-	old_state = new_state = SCTP_CONNTRACK_NONE;
+	old_state = SCTP_CONNTRACK_NONE;
+	new_state = old_state;
 	spin_lock_bh(&ct->lock);
 	for_each_sctp_chunk (skb, sch, _sch, offset, dataoff, count) {
 		/* Special cases of Verification tag check (Sec 8.5.1) */
-- 
2.11.0
