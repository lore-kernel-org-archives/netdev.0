From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH] NetLabel: parse the CIPSO ranged tag on incoming packets
Date: Mon, 12 Mar 2007 09:45:54 -0400
Message-ID: <20070312134615.294091233@flek.zko.hp.com>
Cc: Paul Moore <paul.moore@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:54987 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965627AbXCLNrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 09:47:22 -0400
Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel6.hp.com (Postfix) with ESMTP id D499D3614E
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 09:47:21 -0400 (EDT)
Content-Disposition: inline; filename=netlabel-cipso_missing_range
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 484b366932be0b73a22c74a82748ca10a721643e added support for the CIPSO
ranged categories tag.  However, it appears that I made a mistake when rebasing
then patch to the latest upstream sources for submission and dropped the part
of the patch that actually parses the tag on incoming packets.  This patch
fixes this mistake by adding the required function call to the
cipso_v4_skbuff_getattr() function.

I've run this patch over the weekend and have not noticed any problems.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: net-2.6_bugfix_2/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6_bugfix_2.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6_bugfix_2/net/ipv4/cipso_ipv4.c
@@ -1933,6 +1933,11 @@ int cipso_v4_skbuff_getattr(const struct
 						 &cipso_ptr[6],
 						 secattr);
 		break;
+	case CIPSO_V4_TAG_RANGE:
+		ret_val = cipso_v4_parsetag_rng(doi_def,
+						&cipso_ptr[6],
+						secattr);
+		break;
 	}
 
 skbuff_getattr_return:

--
paul moore
linux security @ hp

