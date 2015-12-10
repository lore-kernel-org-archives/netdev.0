From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 4/4] elevator: use list_is_{first,last}
Date: Thu, 10 Dec 2015 22:20:00 +0800
Message-ID: <4f2d53c2ddbc9c0d4b00b4db1bd797b53faf8c2d.1449755818.git.geliangtang@163.com>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com> <394e9e5ece944969fe1ff4f37c9a73bf5543265e.1449755818.git.geliangtang@163.com> <b415535e3c9784ee8529b3e7372b94e759b48bf4.1449755818.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Seth Jennings <sjenning@redhat.com>,
	Jiri Kosina <jikos@kernel.org>,
	Vojtech Pavlik <vojtech@suse.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	live-patching@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jens Axboe <axboe@kernel.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-134.163.com ([123.125.50.134]:39084 "EHLO m50-134.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324AbbLJOXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 09:23:01 -0500
In-Reply-To: <b415535e3c9784ee8529b3e7372b94e759b48bf4.1449755818.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For better readability, use list_is_{first,last}() instead of open-coded.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 block/noop-iosched.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/block/noop-iosched.c b/block/noop-iosched.c
index a163c48..d44326e 100644
--- a/block/noop-iosched.c
+++ b/block/noop-iosched.c
@@ -44,7 +44,7 @@ noop_former_request(struct request_queue *q, struct request *rq)
 {
 	struct noop_data *nd = q->elevator->elevator_data;
 
-	if (rq->queuelist.prev == &nd->queue)
+	if (list_is_first(&rq->queuelist, &nd->queue))
 		return NULL;
 	return list_prev_entry(rq, queuelist);
 }
@@ -54,7 +54,7 @@ noop_latter_request(struct request_queue *q, struct request *rq)
 {
 	struct noop_data *nd = q->elevator->elevator_data;
 
-	if (rq->queuelist.next == &nd->queue)
+	if (list_is_last(&rq->queuelist, &nd->queue))
 		return NULL;
 	return list_next_entry(rq, queuelist);
 }
-- 
2.5.0
