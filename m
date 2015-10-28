From: Loganaden Velvindron <logan@elandsys.com>
Subject: [PATCH net-next] use vzalloc() instead of vmalloc() as counterstmp
 is not cleared before it is used in get_counters(). counterstmp might be
 leaked partially when it is sent to userland later on.
Date: Wed, 28 Oct 2015 08:54:20 -0700
Message-ID: <20151028155420.GA21173@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.qubic.net ([208.69.177.116]:64669 "EHLO mx.elandsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965806AbbJ1QAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 12:00:03 -0400
Received: from mx.elandsys.com (IDENT:logan@localhost [127.0.0.1])
	by mx.elandsys.com (8.14.5/8.14.5) with ESMTP id t9SFsKcw020828
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 08:54:21 -0700 (PDT)
Received: (from logan@localhost)
	by mx.elandsys.com (8.14.5/8.14.5/Submit) id t9SFsKiw005523
	for netdev@vger.kernel.org; Wed, 28 Oct 2015 08:54:20 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 net/bridge/netfilter/ebtables.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index f46ca41..26922e9 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -989,7 +989,7 @@ static int do_replace_finish(struct net *net, struct ebt_replace *repl,
 	   the check on the size is done later, when we have the lock */
 	if (repl->num_counters) {
 		unsigned long size = repl->num_counters * sizeof(*counterstmp);
-		counterstmp = vmalloc(size);
+		counterstmp = vzalloc(size);
 		if (!counterstmp)
 			return -ENOMEM;
 	}
@@ -1410,7 +1410,7 @@ static int copy_counters_to_user(struct ebt_table *t,
 		return -EINVAL;
 	}
 
-	counterstmp = vmalloc(nentries * sizeof(*counterstmp));
+	counterstmp = vzalloc(nentries * sizeof(*counterstmp));
 	if (!counterstmp)
 		return -ENOMEM;
 
-- 
2.6.1
