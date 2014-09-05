From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2] ip link: restore backward compatibility with 'ip link add ifname'
Date: Fri,  5 Sep 2014 12:00:21 +0200
Message-ID: <1409911221-7580-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1409909845-7126-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43080 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756192AbaIEKA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 06:00:28 -0400
In-Reply-To: <1409909845-7126-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9a02651a87d0 ("ip: check for missing dev arg when doing VF rate"),
breaks backward compatibility. Before the commit, this kind of
command was allowed:
ip link add myiface type ...
Now, it returns an error, we should add the arg 'name':
ip link add name myiface type ...

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/iplink.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 1a907d998a87..ea06871b7c81 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -593,8 +593,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
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
