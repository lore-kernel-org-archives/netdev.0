From: Thomas Egerer <thomas.egerer@secunet.com>
Subject: [PATCH] ipv6: Remove hoplimit initialization to -1
Date: Thu, 21 Apr 2011 10:56:02 +0200
Message-ID: <4DAFF122.7010608@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000608000401070609090500"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42323 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318Ab1DUIzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 04:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000608000401070609090500
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit


The changes introduced with git-commit a02e4b7d missed to remove the
hoplimit initialization. As a result, ipv6_get_mtu interprets the return
value of dst_metric_raw (-1) as 255 and answers ping6 with this hoplimit.
This patche removes the line such that ping6 is answered with the
hoplimit value configured via sysctl.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
---
 net/ipv6/route.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)



--------------000608000401070609090500
Content-Type: text/x-patch;
 name="0001-ipv6-Remove-hoplimit-initialization-to-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-ipv6-Remove-hoplimit-initialization-to-1.patch"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 843406f..0a5d02a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2012,7 +2012,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->dst.output = ip6_output;
 	rt->rt6i_dev = net->loopback_dev;
 	rt->rt6i_idev = idev;
-	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, -1);
 	rt->dst.obsolete = -1;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;


--------------000608000401070609090500--
