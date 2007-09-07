From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] Freeing alive inet6 address
Date: Fri, 7 Sep 2007 14:21:18 +0400
Message-ID: <20070907102118.GA27780@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devel@openvz.org
To: den@openvz.org, adobriyan@openvz.org, xemul@openvz.org,
	dev@openvz.org, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:56604 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965128AbXIGLAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 07:00:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis V. Lunev <den@openvz.org>

addrconf_dad_failure calls addrconf_dad_stop which takes referenced address
and drops the count. So, in6_ifa_put perrformed at out: is extra. This
results in message: "Freeing alive inet6 address" and not released dst entries.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Signed-off-by: Alexey Dobriyan <adobriyan@openvz.org>

--- ./net/ipv6/ndisc.c.ipv6dad	2007-09-03 16:54:32.000000000 +0400
+++ ./net/ipv6/ndisc.c	2007-09-07 13:34:30.000000000 +0400
@@ -736,7 +736,7 @@ static void ndisc_recv_ns(struct sk_buff
 				 * so fail our DAD process
 				 */
 				addrconf_dad_failure(ifp);
-				goto out;
+				return;
 			} else {
 				/*
 				 * This is not a dad solicitation.
