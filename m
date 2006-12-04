From: Patrick McHardy <kaber@trash.net>
Subject: RFC: consistent disable_xfrm behaviour
Date: Mon, 04 Dec 2006 15:59:54 +0100
Message-ID: <457437EA.7000406@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030406050300030204020307"
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46713 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936971AbWLDO4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 09:56:47 -0500
Received: from [192.168.0.100] (unknown [195.158.167.17])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id A4D67948A9
	for <netdev@vger.kernel.org>; Mon,  4 Dec 2006 15:56:45 +0100 (MET)
To: Linux Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030406050300030204020307
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Currently the behaviour of disable_xfrm is inconsistent between
locally generated and forwarded packets. For locally generated
packets disable_xfrm disables the policy lookup if it is set on
the output device, for forwarded traffic however it looks at the
input device. This makes it impossible to disable xfrm on all
devices but a dummy device and use normal routing to direct
traffic to that device.

The Documentation is not exactly clear about whether the input
or output device is meant, but the way I read it talks about
the output device as well (since encryption is only done at
output):

disable_xfrm - BOOLEAN

        Disable IPSEC encryption on this interface, whatever the policy

Opinions?


--------------030406050300030204020307
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9f3924c..164a7ee 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1780,7 +1780,7 @@ #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 #endif
 	if (in_dev->cnf.no_policy)
 		rth->u.dst.flags |= DST_NOPOLICY;
-	if (in_dev->cnf.no_xfrm)
+	if (out_dev->cnf.no_xfrm)
 		rth->u.dst.flags |= DST_NOXFRM;
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;

--------------030406050300030204020307--
