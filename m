From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH]: ipsecv6 needs a space when printing audit record.
Date: Mon, 19 Mar 2007 18:14:59 -0600
Message-ID: <200703200014.l2K0ExTL015802@faith.austin.ibm.com>
Cc: davem@davemloft.net, eparis@redhat.com, redhat-lspp@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:39723 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030784AbXCTAbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 20:31:17 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2K0VGuT014866
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 20:31:16 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2K0VGnm065920
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 18:31:16 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2K0VG3V002775
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 18:31:16 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a space between printing of the src and dst ipv6 addresses.
Otherwise, audit or other test tools may fail to process the audit
record properly because they cannot find the dst address.

Please let me know if this patch is ok. It is minor fix, but I have
tested it and printing ipsecv6 audit record is much better.

Regards,
Joy

Signed-off-by: Joy Latten <latten@austin.ibm.com>

Patch is against linux-2.6.20-rc4.

diff -urpN linux-2.6.20.orig/net/xfrm/xfrm_policy.c linux-2.6.20.patch/net/xfrm/xfrm_policy.c
--- linux-2.6.20.orig/net/xfrm/xfrm_policy.c	2007-03-16 17:21:27.000000000 -0500
+++ linux-2.6.20.patch/net/xfrm/xfrm_policy.c	2007-03-19 18:39:09.000000000 -0500
@@ -2089,7 +2089,7 @@ void xfrm_audit_log(uid_t auid, u32 sid,
 					sizeof(struct in6_addr));
 			}
 			audit_log_format(audit_buf,
-					 " src=" NIP6_FMT "dst=" NIP6_FMT,
+					 " src=" NIP6_FMT " dst=" NIP6_FMT,
 					 NIP6(saddr6), NIP6(daddr6));
 		}
 		break;
