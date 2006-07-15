From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: Re: [RFC] HTB initialize upper bound properly
Date: Sun, 16 Jul 2006 00:09:58 +0900
Message-ID: <20060716000958.671e8da7.yoichi_yuasa@tripeaks.co.jp>
References: <20060714120341.0c7f4466@dxpl.pdx.osdl.net>
	<1152914786.16981.25.camel@jzny2>
	<20060714.163245.106771234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, hadi@cyberus.ca, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo30.po.2iij.net ([210.128.50.53]:26388 "EHLO mo30.po.2iij.net")
	by vger.kernel.org with ESMTP id S1750705AbWGOPKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 11:10:12 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060714.163245.106771234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006 16:32:45 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jamal Hadi Salim <hadi@cyberus.ca>
> Date: Fri, 14 Jul 2006 18:06:26 -0400
> 
> > On Fri, 2006-14-07 at 12:03 -0700, Stephen Hemminger wrote:
> > > The upper bound for HTB time diff needs to be scaled to PSCHED
> > > units rather than just assuming usecs.  The field mbuffer is used
> > > in TDIFF_SAFE(), as an upper bound.  Untested...
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > 
> > Looks good to me.
> 
> Me too, thanks Stephen.

You forgot a semicolon.

Yoichi

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X 2.6.18-rc1/Documentation/dontdiff 2.6.18-rc1-orig/net/sched/sch_htb.c 2.6.18-rc1/net/sched/sch_htb.c
--- 2.6.18-rc1-orig/net/sched/sch_htb.c	2006-07-15 17:16:48.561070000 +0900
+++ 2.6.18-rc1/net/sched/sch_htb.c	2006-07-15 17:15:44.513067250 +0900
@@ -1601,7 +1601,7 @@ static int htb_change_class(struct Qdisc
 		/* set class to be in HTB_CAN_SEND state */
 		cl->tokens = hopt->buffer;
 		cl->ctokens = hopt->cbuffer;
-		cl->mbuffer = PSCHED_JIFFIE2US(HZ*60) /* 1min */
+		cl->mbuffer = PSCHED_JIFFIE2US(HZ*60); /* 1min */
 		PSCHED_GET_TIME(cl->t_c);
 		cl->cmode = HTB_CAN_SEND;
 
