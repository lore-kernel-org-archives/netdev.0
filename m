From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipx: remove all unnecessary castings on ntohl
Date: Wed, 29 Oct 2014 09:31:42 +0100
Message-ID: <1414571502-9231-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apply commit e0f36310f793
("ipx: remove unnecessary casting on ntohl")
to all seq_printf/08lX

Inspired-by: "David S. Miller" <davem@davemloft.net>
Inspired-by: Joe Perches <joe@perches.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipx/ipx_proc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
index 8391191..c1d247e 100644
--- a/net/ipx/ipx_proc.c
+++ b/net/ipx/ipx_proc.c
@@ -45,7 +45,7 @@ static int ipx_seq_interface_show(struct seq_file *seq, void *v)
 	}
 
 	i = list_entry(v, struct ipx_interface, node);
-	seq_printf(seq, "%08lX   ", (unsigned long int)ntohl(i->if_netnum));
+	seq_printf(seq, "%08X   ", ntohl(i->if_netnum));
 	seq_printf(seq, "%02X%02X%02X%02X%02X%02X   ",
 			i->if_node[0], i->if_node[1], i->if_node[2],
 			i->if_node[3], i->if_node[4], i->if_node[5]);
@@ -87,7 +87,7 @@ static int ipx_seq_route_show(struct seq_file *seq, void *v)
 
 	rt = list_entry(v, struct ipx_route, node);
 
-	seq_printf(seq, "%08lX   ", (unsigned long int)ntohl(rt->ir_net));
+	seq_printf(seq, "%08X   ", ntohl(rt->ir_net));
 	if (rt->ir_routed)
 		seq_printf(seq, "%08X     %02X%02X%02X%02X%02X%02X\n",
 			   ntohl(rt->ir_intrfc->if_netnum),
@@ -194,19 +194,19 @@ static int ipx_seq_socket_show(struct seq_file *seq, void *v)
 	s = v;
 	ipxs = ipx_sk(s);
 #ifdef CONFIG_IPX_INTERN
-	seq_printf(seq, "%08lX:%02X%02X%02X%02X%02X%02X:%04X  ",
-		   (unsigned long)ntohl(ipxs->intrfc->if_netnum),
+	seq_printf(seq, "%08X:%02X%02X%02X%02X%02X%02X:%04X  ",
+		   ntohl(ipxs->intrfc->if_netnum),
 		   ipxs->node[0], ipxs->node[1], ipxs->node[2], ipxs->node[3],
 		   ipxs->node[4], ipxs->node[5], ntohs(ipxs->port));
 #else
-	seq_printf(seq, "%08lX:%04X  ", (unsigned long) ntohl(ipxs->intrfc->if_netnum),
+	seq_printf(seq, "%08X:%04X  ", ntohl(ipxs->intrfc->if_netnum),
 		   ntohs(ipxs->port));
 #endif	/* CONFIG_IPX_INTERN */
 	if (s->sk_state != TCP_ESTABLISHED)
 		seq_printf(seq, "%-28s", "Not_Connected");
 	else {
-		seq_printf(seq, "%08lX:%02X%02X%02X%02X%02X%02X:%04X  ",
-			   (unsigned long)ntohl(ipxs->dest_addr.net),
+		seq_printf(seq, "%08X:%02X%02X%02X%02X%02X%02X:%04X  ",
+			   ntohl(ipxs->dest_addr.net),
 			   ipxs->dest_addr.node[0], ipxs->dest_addr.node[1],
 			   ipxs->dest_addr.node[2], ipxs->dest_addr.node[3],
 			   ipxs->dest_addr.node[4], ipxs->dest_addr.node[5],
-- 
1.9.3
