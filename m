From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH] net: missing call of trace_napi_poll in busy_poll_stop
Date: Fri, 25 Aug 2017 15:04:32 +0200
Message-ID: <150366627224.16965.12554507587831320156.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57796 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755340AbdHYNEg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 09:04:36 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id BB3CE61462
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 13:04:36 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed that busy_poll_stop() also invoke the drivers napi->poll()
function pointer, but didn't have an associated call to trace_napi_poll()
like all other call sites.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/dev.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 270b54754821..a24d2fb691ed 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5319,6 +5319,7 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
 	 * Ideally, a new ndo_busy_poll_stop() could avoid another round.
 	 */
 	rc = napi->poll(napi, BUSY_POLL_BUDGET);
+	trace_napi_poll(napi, rc, BUSY_POLL_BUDGET);
 	netpoll_poll_unlock(have_poll_lock);
 	if (rc == BUSY_POLL_BUDGET)
 		__napi_schedule(napi);
