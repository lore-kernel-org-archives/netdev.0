From: jamal <hadi@cyberus.ca>
Subject: [PATCH]net-sched: Fix actions referencing
Date: Thu, 07 Aug 2008 05:42:57 -0400
Message-ID: <1218102177.12799.12.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wEdJ8d2hHRftx8Eqvdkk"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:50020 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbYHGMlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:41:20 -0400
Received: by an-out-0708.google.com with SMTP id d40so72012and.103
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 05:41:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wEdJ8d2hHRftx8Eqvdkk
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Noticed while exercising Denys' iproute changes.

cheers,
jamal

--=-wEdJ8d2hHRftx8Eqvdkk
Content-Disposition: attachment; filename=act_r
Content-Type: text/plain; name=act_r; charset=us-ascii
Content-Transfer-Encoding: 7bit

net-sched: Fix actions referencing

When an action is added several times with the same exact index
it gets deleted on every even-numbered attempt.
This fixes that issue.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 82ca26fa474171326de9851a2f547c490f8e7276
tree 04ebfd9dcb15d463a0e49740940f0c8e86916a25
parent bb7564f1e081c18dae905c8fc871269f4a81ba99
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Aug 2008 05:37:51 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Aug 2008 05:37:51 -0400

 net/sched/act_api.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d308c19..26c7e1f 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -205,10 +205,9 @@ struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind,
 {
 	struct tcf_common *p = NULL;
 	if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
-		if (bind) {
+		if (bind)
 			p->tcfc_bindcnt++;
-			p->tcfc_refcnt++;
-		}
+		p->tcfc_refcnt++;
 		a->priv = p;
 	}
 	return p;

--=-wEdJ8d2hHRftx8Eqvdkk--

