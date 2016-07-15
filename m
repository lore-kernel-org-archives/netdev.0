From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH] net: fixup for tracepoint napi:napi_poll
Date: Fri, 15 Jul 2016 23:55:20 +0200
Message-ID: <20160715215520.13891.51701.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175AbcGOVzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 17:55:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent change to tracepoint napi:napi_poll changed the order of
the parameters that perf scripts sees, the printk was correct.  The
problem was that the new parameters (work and budget) were pushed
in front of dev_name.

The new parameters obviously need to be appended to keep backward
compatible.

Fixes: 1db19db7f5ff ("net: tracepoint napi:napi_poll add work and budget")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/napi.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/napi.h b/include/trace/events/napi.h
index 118ed7767639..0b9e5136a2a3 100644
--- a/include/trace/events/napi.h
+++ b/include/trace/events/napi.h
@@ -18,16 +18,16 @@ TRACE_EVENT(napi_poll,
 
 	TP_STRUCT__entry(
 		__field(	struct napi_struct *,	napi)
+		__string(	dev_name, napi->dev ? napi->dev->name : NO_DEV)
 		__field(	int,			work)
 		__field(	int,			budget)
-		__string(	dev_name, napi->dev ? napi->dev->name : NO_DEV)
 	),
 
 	TP_fast_assign(
 		__entry->napi = napi;
+		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
 		__entry->work = work;
 		__entry->budget = budget;
-		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
 	),
 
 	TP_printk("napi poll on napi struct %p for device %s work %d budget %d",
