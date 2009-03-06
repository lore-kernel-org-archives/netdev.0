From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 2/2] Doc: Fix wrong API example usage of call_rcu().
Date: Fri, 06 Mar 2009 14:27:38 +0100
Message-ID: <20090306132738.15896.2226.stgit@localhost.localdomain>
References: <20090306132732.15896.96543.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:45514 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660AbZCFNxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 08:53:23 -0500
In-Reply-To: <20090306132732.15896.96543.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At some point the API of call_rcu() changed from three parameters
to two parameters, correct the documentation.

One confusing thing in RCU/listRCU.txt, which is NOT fixed in this patch,
is that no reason or explaination is given for using call_rcu() instead of
the normal synchronize_rcu() call.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 Documentation/RCU/listRCU.txt |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/RCU/listRCU.txt b/Documentation/RCU/listRCU.txt
index 1fd1753..4349c14 100644
--- a/Documentation/RCU/listRCU.txt
+++ b/Documentation/RCU/listRCU.txt
@@ -118,7 +118,7 @@ Following are the RCU equivalents for these two functions:
 		list_for_each_entry(e, list, list) {
 			if (!audit_compare_rule(rule, &e->rule)) {
 				list_del_rcu(&e->list);
-				call_rcu(&e->rcu, audit_free_rule, e);
+				call_rcu(&e->rcu, audit_free_rule);
 				return 0;
 			}
 		}
@@ -206,7 +206,7 @@ RCU ("read-copy update") its name.  The RCU code is as follows:
 				ne->rule.action = newaction;
 				ne->rule.file_count = newfield_count;
 				list_replace_rcu(e, ne);
-				call_rcu(&e->rcu, audit_free_rule, e);
+				call_rcu(&e->rcu, audit_free_rule);
 				return 0;
 			}
 		}
@@ -283,7 +283,7 @@ flag under the spinlock as follows:
 				list_del_rcu(&e->list);
 				e->deleted = 1;
 				spin_unlock(&e->lock);
-				call_rcu(&e->rcu, audit_free_rule, e);
+				call_rcu(&e->rcu, audit_free_rule);
 				return 0;
 			}
 		}

