From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 3/3] netem: fix gemodel loss generator
Date: Fri, 29 Nov 2013 11:04:26 -0800
Message-ID: <20131129110426.5aa54569@nehalam.linuxnetplumber.net>
References: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Martin Burri <martin.burri@ch.abb.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:40676 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821Ab3K2TEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 14:04:34 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so14268089pde.13
        for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 11:04:34 -0800 (PST)
In-Reply-To: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch from developers of the alternative loss models, downloaded from:
   http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG

 "in case 2, of the switch we change the direction of the inequality to
  net_random()>clg->a3, because clg->a3 is h in the GE model and when h
  is 0 all packets will be lost."

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/sched/sch_netem.c	2013-11-29 10:58:49.441419081 -0800
+++ b/net/sched/sch_netem.c	2013-11-29 10:58:55.313369015 -0800
@@ -272,7 +272,7 @@ static bool loss_gilb_ell(struct netem_s
 	case 2:
 		if (net_random() < clg->a2)
 			clg->state = 1;
-		if (clg->a3 > net_random())
+		if (net_random() > clg->a3)
 			return true;
 	}
 
