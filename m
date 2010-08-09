From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/2] pkt_sched: sch_sfq: Add dummy unbind_tcf and put
 handles. Was: [PATCH] sfq: add dummy bind/unbind handles
Date: Tue, 10 Aug 2010 00:18:17 +0200
Message-ID: <20100809221817.GA18629@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Franchoze Eric <franchoze@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53373 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab0HIWSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 18:18:25 -0400
Received: by bwz3 with SMTP id 3so1537659bwz.19
        for <netdev@vger.kernel.org>; Mon, 09 Aug 2010 15:18:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Franchoze Eric wrote, On 08/09/2010 05:01 PM:
> 
> 08.08.10, 11:04, "Jarek Poplawski" <jarkao2@gmail.com>:
> 
>> David Miller wrote, On 08.08.2010 07:45:
...
>>  > Agreed, I can't see a way that unbind can ever be invoked
>>  > if the bind call always returns zero.
>>  
>>  To tell the truth, I think unbind should be implemented anyway,
>>  just for consistency, safety, and easier verification. But, looking
>>  at a similar case of .get and .put in the same driver, Patrick
>>  seemed to do it purposely, so I expected some discussion about the
>>  rules yet, and made it minimal to ease merging to older kernels.
...
> 
> As for me it's better to add unbind now that get unexpected null derefance in future with API changing...

Here is my proposal which adds both unbind and put, plus some early
verification (the next patch). Of course, there is still Stephen's
alternative with later checks.

Jarek P.
----------------->
Add dummy .unbind_tcf and .put qdisc class ops for easier verification.
(All other schedulers have it like this.)

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 534f332..d8e0ae5 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -519,6 +519,10 @@ static unsigned long sfq_bind(struct Qdisc *sch, unsigned long parent,
 	return 0;
 }
 
+static void sfq_put(struct Qdisc *q, unsigned long cl)
+{
+}
+
 static struct tcf_proto **sfq_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
@@ -572,8 +576,10 @@ static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 
 static const struct Qdisc_class_ops sfq_class_ops = {
 	.get		=	sfq_get,
+	.put		=	sfq_put,
 	.tcf_chain	=	sfq_find_tcf,
 	.bind_tcf	=	sfq_bind,
+	.unbind_tcf	=	sfq_put,
 	.dump		=	sfq_dump_class,
 	.dump_stats	=	sfq_dump_class_stats,
 	.walk		=	sfq_walk,
