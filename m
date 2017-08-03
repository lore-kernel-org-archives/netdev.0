From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH iproute2 net-next] iproute: Display offload indication per-nexthop
Date: Thu,  3 Aug 2017 09:13:55 +0300
Message-ID: <20170803061355.6474-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, jiri@mellanox.com, dsahern@gmail.com,
        mlxsw@mellanox.com, Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50041.outbound.protection.outlook.com ([40.107.5.41]:14829
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751062AbdHCGOR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 02:14:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since kernel commit 475abbf1ef67 ("ipv4: fib: Set offload indication
according to nexthop flags") offload indication is reported on a
per-nexthop basis.

Adjust iproute2 to display it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 ip/iproute.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index cb695ad..39af38c 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -696,6 +696,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				fprintf(fp, "onlink ");
 			if (nh->rtnh_flags & RTNH_F_PERVASIVE)
 				fprintf(fp, "pervasive ");
+			if (nh->rtnh_flags & RTNH_F_OFFLOAD)
+				fprintf(fp, "offload ");
 			if (nh->rtnh_flags & RTNH_F_LINKDOWN)
 				fprintf(fp, "linkdown ");
 			len -= NLMSG_ALIGN(nh->rtnh_len);
-- 
2.9.4
