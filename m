From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/3 net-next] pkt_sched: sch_htb: Warn on too many
	events.
Date: Fri, 30 Jan 2009 10:17:15 +0000
Message-ID: <20090130101714.GB8882@ff.dom.local>
References: <20090128125230.GA6282@ff.dom.local> <49808544.5010304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:50993 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433AbZA3KRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 05:17:21 -0500
Received: by ewy14 with SMTP id 14so634277ewy.13
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 02:17:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49808544.5010304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------------------> PATCH 2/3
pkt_sched: sch_htb: Warn on too many events.

Let's get some info on possible config problems. This patch brings
back an old warning, but is printed only once now.

With feedback from Patrick McHardy <kaber@trash.net>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff -Nurp b/net/sched/sch_htb.c c/net/sched/sch_htb.c
--- b/net/sched/sch_htb.c	2009-01-29 22:07:42.000000000 +0000
+++ c/net/sched/sch_htb.c	2009-01-30 08:48:41.000000000 +0000
@@ -153,6 +153,9 @@ struct htb_sched {
 	int direct_qlen;	/* max qlen of above */
 
 	long direct_pkts;
+
+#define HTB_WARN_TOOMANYEVENTS	0x1
+	unsigned int warned;	/* only one warning */
 };
 
 /* find class in global hash table using given handle */
@@ -685,6 +688,10 @@ static psched_time_t htb_do_events(struc
 			htb_add_to_wait_tree(q, cl, diff);
 	}
 	/* too much load - let's continue on next jiffie (including above) */
+	if (!(q->warned & HTB_WARN_TOOMANYEVENTS)) {
+		printk(KERN_WARNING "htb: too many events!\n");
+		q->warned |= HTB_WARN_TOOMANYEVENTS;
+	}
 	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
 }
 
