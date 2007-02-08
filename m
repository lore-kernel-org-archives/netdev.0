From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 1/5] NET : Introduce union in struct dst_entry to hold 'next'
 pointer
Date: Thu, 08 Feb 2007 22:33:09 +0100
Message-ID: <45CB9715.5000509@cosmosbay.com>
References: <20070208093935.90CA.SHINTA@sfc.wide.ad.jp> <20070207.165213.98418769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080309010305060907060809"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54106 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423426AbXBHVdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:33:20 -0500
In-Reply-To: <20070207.165213.98418769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080309010305060907060809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch introduces an anonymous union to nicely express the fact that all 
objects inherited from struct dst_entry should access to the generic 'next' 
pointer but with appropriate type verification.

This patch is a prereq before following patches.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------080309010305060907060809
Content-Type: text/plain;
 name="introduce_union_in_dst_entry.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="introduce_union_in_dst_entry.patch"

--- linux-2.6.20/include/net/dst.h	2007-02-08 21:06:15.000000000 +0100
+++ linux-2.6.20-ed/include/net/dst.h	2007-02-08 21:07:21.000000000 +0100
@@ -37,7 +37,12 @@ struct sk_buff;
 
 struct dst_entry
 {
-	struct dst_entry        *next;
+	union {
+		struct dst_entry *next;
+		struct rtable    *rt_next;
+		struct rt6_info   *rt6_next;
+		struct dn_route  *dn_next;
+	};
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
 	struct dst_entry	*child;

--------------080309010305060907060809--
