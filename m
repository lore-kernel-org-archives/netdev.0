From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Wed, 22 Oct 2008 16:46:36 -0700 (PDT)
Message-ID: <20081022.164636.143240158.davem@davemloft.net>
References: <200810221635.10268.jk@ozlabs.org>
	<48FF249C.5040207@hp.com>
	<200810230954.02499.jk@ozlabs.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Wed_Oct_22_16_46_36_2008_228)--"
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org
To: jk@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751331AbYJVXq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 19:46:59 -0400
In-Reply-To: <200810230954.02499.jk@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----Next_Part(Wed_Oct_22_16_46_36_2008_228)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

From: Jeremy Kerr <jk@ozlabs.org>
Date: Thu, 23 Oct 2008 09:54:02 +1100

> > Oddly enough, none of this series made it to patchwork.
> 
> I'll chase this up then - could you formward a copy of one of the 
> messages after it has come through the list?

Here is one of them.


----Next_Part(Wed_Oct_22_16_46_36_2008_228)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="x.txt"

Return-Path: <vladislav.yasevich@hp.com>
X-Original-To: davem@davemloft.net
Delivered-To: davem@davemloft.net
Received: from g5t0008.atlanta.hp.com (g5t0008.atlanta.hp.com [15.192.0.45])
	by sunset.davemloft.net (Postfix) with ESMTP id B6A09C8C192
	for <davem@davemloft.net>; Tue, 21 Oct 2008 19:08:29 -0700 (PDT)
Received: from smtp2.fc.hp.com (smtp.cnd.hp.com [15.11.136.114])
	by g5t0008.atlanta.hp.com (Postfix) with ESMTP id 7C98524554;
	Wed, 22 Oct 2008 02:08:50 +0000 (UTC)
Received: from localhost.localdomain (squirrel.fc.hp.com [15.11.146.57])
	by smtp2.fc.hp.com (Postfix) with ESMTP id 3B1CC2892FA;
	Wed, 22 Oct 2008 01:55:45 +0000 (UTC)
From: Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/4] sctp: Drop ICMP packet too big message with MTU larger than current PMTU
Date: Tue, 21 Oct 2008 22:08:44 -0400
Message-Id: <1224641327-11913-2-git-send-email-vladislav.yasevich@hp.com>
X-Mailer: git-send-email 1.5.3.5
In-Reply-To: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If ICMP packet too big message is received with MTU larger than current
PMTU, SCTP will still accept this ICMP message and sync the PMTU of assoc
with the wrong MTU.

Endpoing A                 Endpoint B
(ESTABLISHED)              (ESTABLISHED)
ICMP         --------->
(packet too big, MTU too larger)
                           sync PMTU

This patch fixed the problem by drop that ICMP message.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index a49fa80..bf612d9 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -369,7 +369,7 @@ static void sctp_add_backlog(struct sock *sk, struct sk_buff *skb)
 void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 			   struct sctp_transport *t, __u32 pmtu)
 {
-	if (!t || (t->pathmtu == pmtu))
+	if (!t || (t->pathmtu <= pmtu))
 		return;
 
 	if (sock_owned_by_user(sk)) {
-- 
1.5.3.5


----Next_Part(Wed_Oct_22_16_46_36_2008_228)----
