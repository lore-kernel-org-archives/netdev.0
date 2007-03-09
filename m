From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Fix for ipv6_setsockopt NULL dereference
Date: Fri, 9 Mar 2007 15:15:54 +0100
Message-ID: <200703091515.55985.olaf.kirch@oracle.com>
References: <200703091207.31877.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:57576 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767302AbXCIORD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 09:17:03 -0500
Received: from rgmgw1.us.oracle.com (rgmgw1.us.oracle.com [138.1.186.110])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id l29EGwIs021304
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 08:17:00 -0600
Received: from rcsmt250.oracle.com (rcsmt250.oracle.com [148.87.90.195])
	by rgmgw1.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id l29D60n8023927
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 07:16:57 -0700
In-Reply-To: <200703091207.31877.olaf.kirch@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I came across this bug in http://bugzilla.kernel.org/show_bug.cgi?id=8155

Here's a potential fix.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
--
Fix NULL pointer derefence in ipv6_setsockopt, as described in bug #8155.

Signed-off-by: olaf.kirch@oracle.com

---
 net/ipv6/ipv6_sockglue.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: build-2.6/net/ipv6/ipv6_sockglue.c
===================================================================
--- build-2.6.orig/net/ipv6/ipv6_sockglue.c
+++ build-2.6/net/ipv6/ipv6_sockglue.c
@@ -413,7 +413,7 @@ static int do_ipv6_setsockopt(struct soc
 		}
 
 		/* routing header option needs extra check */
-		if (optname == IPV6_RTHDR && opt->srcrt) {
+		if (optname == IPV6_RTHDR && opt && opt->srcrt) {
 			struct ipv6_rt_hdr *rthdr = opt->srcrt;
 			switch (rthdr->type) {
 			case IPV6_SRCRT_TYPE_0:
