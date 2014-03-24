From: Wei Zhang <asuka.com@163.com>
Subject: [PATCH] ipv4: gre: Fix null pointer dereference in gre_cisco_err()
Date: Mon, 24 Mar 2014 15:34:31 +0800
Message-ID: <1395646471-637-1-git-send-email-asuka.com@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wei Zhang <asuka.com@163.com>
To: xeb@mail.ru, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When use the gre vport, openvswitch register a gre_cisco_protocol but
does not supply a err_handler with it. The gre_cisco_err() call the
err_handler without existence check, cause the kernel crash.

This patch base on v3.14-rc7. But the bug affect all kernel newer than
3.11!

Signed-off-by: Wei Zhang <asuka.com@163.com>
---
 net/ipv4/gre_demux.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 1863422..56b0d67 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -250,7 +250,7 @@ static void gre_cisco_err(struct sk_buff *skb, u32 info)
 		struct gre_cisco_protocol *proto;
 
 		proto = rcu_dereference(gre_cisco_proto_list[i]);
-		if (!proto)
+		if (!proto || !proto->err_handler)
 			continue;
 
 		if (proto->err_handler(skb, info, &tpi) == PACKET_RCVD)
-- 
1.7.1
