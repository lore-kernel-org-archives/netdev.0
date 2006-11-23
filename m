From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 06/06]: Fix endless loops (part 4): HTB
Date: Thu, 23 Nov 2006 09:44:04 +0100
Message-ID: <45655F54.2020501@trash.net>
References: <20061123083909.GA1586@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32909 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S933269AbWKWIoH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 03:44:07 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061123083909.GA1586@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
>>+static void htb_qlen_notify(struct Qdisc *sch, unsigned long arg)
>>+{
>>+	struct htb_class *cl = (struct htb_class *)arg;
>>+
>>+	if (cl->un.leaf.q->q.qlen == 0)
> 
> 
> Probably "if (cl->prio_activity)" is needed here.


No, the function is only called for active leaf classes, which
always have prio_activity != 0.

> PS: from 00/06:
> 
>>PS: If anyone wants to suggest a nicer name for qdisc_tree_decrease_qlen
>>I'll gladly send new patches :)
> 
> 
> Increasing is nicer so maybe: qdisc_tree_increase_qlen?


But we're decreasing not increasing the qlen, so that doesn't seem
like a good choice :)

