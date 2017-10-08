From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH iproute2 net-next] ip: mroute: Print offload indication
Date: Sun,  8 Oct 2017 17:43:04 +0300
Message-ID: <20171008144304.48850-1-yotamg@mellanox.com>
Cc: stephen@networkplumber.org, davem@davemloft.net,
        mlxsw@mellanox.com, Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50240 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753420AbdJHOnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 10:43:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since kernel net-next commit c7c0bbeae950 ("net: ipmr: Add MFC offload
indication") the kernel indicates on an MFC entry whether it was offloaded
using the RTNH_F_OFFLOAD flag. Update the "ip mroute show" command to
indicate when a route is offloaded, similarly to the "ip route show"
command.

Example output:
$ ip mroute
(0.0.0.0, 239.255.0.1)      Iif: sw1p7  Oifs: t_br0 State: resolved offload
(192.168.1.1, 239.255.0.1)  Iif: sw1p7  Oifs: sw1p4 State: resolved offload

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 ip/ipmroute.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index b51c23c..453a6cf 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -161,6 +161,8 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 	fprintf(fp, " State: %s",
 		r->rtm_flags & RTNH_F_UNRESOLVED ? "unresolved" : "resolved");
+	if (r->rtm_flags & RTNH_F_OFFLOAD)
+		fprintf(fp, " offload");
 	if (show_stats && tb[RTA_MFC_STATS]) {
 		struct rta_mfc_stats *mfcs = RTA_DATA(tb[RTA_MFC_STATS]);
 
-- 
2.8.4
