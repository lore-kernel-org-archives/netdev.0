From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 2/3] netem:  fix loss 4 state model
Date: Fri, 29 Nov 2013 11:03:35 -0800
Message-ID: <20131129110335.0ecaeed8@nehalam.linuxnetplumber.net>
References: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Martin Burri <martin.burri@ch.abb.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:35958 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689Ab3K2TEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 14:04:32 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so14991205pbb.14
        for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 11:04:32 -0800 (PST)
In-Reply-To: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch from developers of the alternative loss models, downloaded from:
   http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG

 "In the case 1 of the switch statement in the if conditions we
   need to add clg->a4 to clg->a1, according to the model."

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/sched/sch_netem.c	2013-11-29 10:55:30.591077393 -0800
+++ b/net/sched/sch_netem.c	2013-11-29 10:58:49.441419081 -0800
@@ -215,10 +215,10 @@ static bool loss_4state(struct netem_sch
 		if (rnd < clg->a4) {
 			clg->state = 4;
 			return true;
-		} else if (clg->a4 < rnd && rnd < clg->a1) {
+		} else if (clg->a4 < rnd && rnd < clg->a1 + clg->a4) {
 			clg->state = 3;
 			return true;
-		} else if (clg->a1 < rnd)
+		} else if (clg->a1 + clg->a4 < rnd)
 			clg->state = 1;
 
 		break;
