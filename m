From: Bart <bwyatt@pavlovmedia.com>
Subject: Practical performance change to qdisc_lookup
Date: Fri, 2 Jul 2010 10:51:42 -0500
Message-ID: <1278085902.16508.149.camel@bwyatt>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pavlovmedia.com ([66.253.253.212]:18679 "EHLO
	mail.pavlovmedia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755262Ab0GBP5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 11:57:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking to speed up our batch processing of many-thousands of TC
rules I stumbled across a usage-based optimization of qdisc_lookup().

while not a algorithmic optimization, I would wager that future rules
are likely to refer to the more recently created qdiscs and not the
oldest ones.

It is silly, but I thought I'd survey opinions on the change.  It is far
less code entropy than say, implementing a hash lookup.

sch_api.c:
@@ -197,7 +197,7 @@
 	    root->handle == handle)
 		return root;
 
-	list_for_each_entry(q, &root->list, list) {
+	list_for_each_entry_reverse(q, &root->list, list) {
 		if (q->handle == handle)
 			return q;
 	}


