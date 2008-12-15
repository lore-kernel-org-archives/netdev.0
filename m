From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Mon, 15 Dec 2008 11:13:08 +0000
Message-ID: <20081215111308.GA5853@ff.dom.local>
References: <20081010075640.GA5204@ff.dom.local> <48EF17EA.5020306@bigtelecom.ru> <20081010090426.GA6054@ff.dom.local> <20081010095129.GB6054@ff.dom.local> <48F6FB3E.7060903@bigtelecom.ru> <20081016084027.GA17632@ff.dom.local> <48FEC302.5090707@bigtelecom.ru> <20081022070200.GB4178@ff.dom.local> <493FDCD4.5020108@bigtelecom.ru> <20081211084606.GA4129@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:7352 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419AbYLOLNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 06:13:17 -0500
Received: by ug-out-1314.google.com with SMTP id 39so166685ugf.37
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 03:13:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081211084606.GA4129@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2008 at 08:46:06AM +0000, Jarek Poplawski wrote:
> On Wed, Dec 10, 2008 at 06:14:28PM +0300, Badalian Vyacheslav wrote:
> > Hello again! Sorry for long away.
> 
> Hi!
> 
> > I was go away from this work for long time.
> > 
> > May we return to this bug?
> > Servers at last stable kernel 2.6.27.8
> > HZ=1000, HR=off, DynamicTicks=off, hysteresis=1
> > Sorry - no patched, update do not i. Do you have fresh patches or ideas
> > for tests?
> 
> Not much, but I can have if you only are willing to test them...
> I attach below a patch which combines 2 patches I sent yesterday to
> netdev (PATCH 7/6 and 8/6) vs. 2.6.27.7 (named testing patch #3 here).
> 
> You can still try the testing patch #2 I sent previously (quoted below)
> with or without this new #3 patch.
> 

Here is another idea worth checking (instead of patch #2).

Jarek P.

--- (testing patch #4)

diff -Nurp a2.6.27.7/net/sched/sch_htb.c b2.6.27.7/net/sched/sch_htb.c
--- a2.6.27.7/net/sched/sch_htb.c	2008-12-11 08:16:16.000000000 +0000
+++ b2.6.27.7/net/sched/sch_htb.c	2008-12-15 10:44:32.000000000 +0000
@@ -924,6 +924,7 @@ static struct sk_buff *htb_dequeue(struc
 		}
 	}
 	sch->qstats.overlimits++;
+	qdisc_watchdog_cancel(&q->watchdog);
 	qdisc_watchdog_schedule(&q->watchdog, next_event);
 fin:
 	return skb;
