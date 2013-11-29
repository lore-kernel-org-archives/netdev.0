From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 1/3] netem: missing break in ge loss generator
Date: Fri, 29 Nov 2013 11:02:43 -0800
Message-ID: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Martin Burri <martin.burri@ch.abb.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:50936 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337Ab3K2TEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 14:04:31 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so14107355pdj.23
        for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 11:04:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a missing break statement in the Gilbert Elliot loss model
generator which makes state machine behave incorrectly.

Reported-by: Martin Burri <martin.burri@ch.abb.com
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/sched/sch_netem.c	2013-11-29 10:40:59.687678738 -0800
+++ b/net/sched/sch_netem.c	2013-11-29 10:46:33.972003879 -0800
@@ -268,6 +268,7 @@ static bool loss_gilb_ell(struct netem_s
 			clg->state = 2;
 		if (net_random() < clg->a4)
 			return true;
+		break;
 	case 2:
 		if (net_random() < clg->a2)
 			clg->state = 1;
