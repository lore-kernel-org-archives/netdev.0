From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: minor optimization in qdisc_qstats_cpu_drop()
Date: Wed, 24 Aug 2016 10:23:34 -0700
Message-ID: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35459 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751044AbcHXRXg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 13:23:36 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so1561088pfg.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 10:23:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

per_cpu_inc() is faster (at least on x86) than per_cpu_ptr(xxx)++;

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sch_generic.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 0d501779cc68f9426e58da6d039dd64adc937c20..52a2015667b49c8315edbb26513a98d4c677fee5 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -592,7 +592,7 @@ static inline void qdisc_qstats_drop(struct Qdisc *sch)
 
 static inline void qdisc_qstats_cpu_drop(struct Qdisc *sch)
 {
-	qstats_drop_inc(this_cpu_ptr(sch->cpu_qstats));
+	this_cpu_inc(sch->cpu_qstats->drops);
 }
 
 static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
