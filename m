From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next iproute2] support batching of ip route get commands
Date: Wed, 15 Jul 2015 17:06:36 -0700
Message-ID: <1437005196-8914-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33716 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbbGPAG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 20:06:59 -0400
Received: by pdbqm3 with SMTP id qm3so33433124pdb.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 17:06:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch replaces exits with returns in
ip route get command handling. This allows batching
of ip route get commands.

$cat route_get_batch.txt
route get 10.0.14.2
route get 12.0.14.2
route get 10.0.14.4

$ip -batch route_get_batch.txt
local 10.0.14.2 dev lo  src 10.0.14.2
    cache <local>
12.0.14.2 via 192.168.0.2 dev eth0  src 192.168.0.15
    cache
10.0.14.4 dev dummy0  src 10.0.14.2
    cache

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/iproute.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 41dea8f..8f49e62 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1682,15 +1682,15 @@ static int iproute_get(int argc, char **argv)
 		req.n.nlmsg_type = RTM_GETROUTE;
 
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
-			exit(2);
+			return -2;
 	}
 
 	if (print_route(NULL, &req.n, (void*)stdout) < 0) {
 		fprintf(stderr, "An error :-)\n");
-		exit(1);
+		return -1;
 	}
 
-	exit(0);
+	return 0;
 }
 
 static int restore_handler(const struct sockaddr_nl *nl,
-- 
1.7.10.4
