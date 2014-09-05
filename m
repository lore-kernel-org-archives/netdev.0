From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] Revert "ip: check for missing dev arg when doing VF rate"
Date: Fri,  5 Sep 2014 11:37:25 +0200
Message-ID: <1409909845-7126-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:42969 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755841AbaIEJhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 05:37:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 9a02651a87d0fd56e2e7eedd63921a050a42b3ec.

This commit breaks backward compatibility. Before the commit, this kind of
command was allowed:
ip link add myiface type ...
Now, it returns an error, we should add the arg 'name':
ip link add name myiface type ...

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/iplink.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 1a907d998a87..bbcdc83d4c91 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -349,7 +349,6 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 
 	if (new_rate_api) {
 		int tmin, tmax;
-
 		if (tivt.min_tx_rate == -1 || tivt.max_tx_rate == -1) {
 			ipaddr_get_vf_rate(tivt.vf, &tmin, &tmax, dev_index);
 			if (tivt.min_tx_rate == -1)
@@ -382,7 +381,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int vf = -1;
 	int numtxqueues = -1;
 	int numrxqueues = -1;
-	int dev_index = 0;
+	int dev_index;
 
 	*group = -1;
 	ret = argc;
@@ -495,9 +494,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			}
 			vflist = addattr_nest(&req->n, sizeof(*req),
 					      IFLA_VFINFO_LIST);
-			if (dev_index == 0)
-				missarg("dev");
-
 			len = iplink_parse_vf(vf, &argc, &argv, req, dev_index);
 			if (len < 0)
 				return -1;
@@ -593,8 +589,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				duparg2("dev", *argv);
 			*dev = *argv;
 			dev_index = ll_name_to_index(*dev);
-			if (dev_index == 0)
-				invarg("Unknown device", *argv);
 		}
 		argc--; argv++;
 	}
-- 
1.9.0
