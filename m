From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net iproute2 v3 1/2] mpls: always set type as RTN_UNICAST for route add/deletes
Date: Mon,  1 Jun 2015 23:29:26 -0700
Message-ID: <1433226567-23302-2-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: ebiederm@xmission.com, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36564 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbbFBG3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 02:29:34 -0400
Received: by pabqy3 with SMTP id qy3so5673740pab.3
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 23:29:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Kernel expects type RTN_UNICAST for mpls route/dels

Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Reviewed-by: Robert Shearman <rshearma@brocade.com> 
---
 ip/iproute.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index 670a4c6..71c088b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -803,6 +803,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 	int scope_ok = 0;
 	int table_ok = 0;
 	int raw = 0;
+	int type_ok = 0;
 
 	memset(&req, 0, sizeof(req));
 
@@ -1095,6 +1096,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			    rtnl_rtntype_a2n(&type, *argv) == 0) {
 				NEXT_ARG();
 				req.r.rtm_type = type;
+				type_ok = 1;
 			}
 
 			if (matches(*argv, "help") == 0)
@@ -1160,6 +1162,9 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 		}
 	}
 
+	if (!type_ok && req.r.rtm_family == AF_MPLS)
+		req.r.rtm_type = RTN_UNICAST;
+
 	if (req.r.rtm_family == AF_UNSPEC)
 		req.r.rtm_family = AF_INET;
 
-- 
1.7.10.4
