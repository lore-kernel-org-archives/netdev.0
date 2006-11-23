From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 06/06]: Fix endless loops (part 4): HTB
Date: Thu, 23 Nov 2006 10:07:32 +0100
Message-ID: <456564D4.9010302@trash.net>
References: <20061123083909.GA1586@ff.dom.local> <45655F54.2020501@trash.net> <20061123090113.GB1586@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:26767 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S933340AbWKWJHh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 04:07:37 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061123090113.GB1586@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Thu, Nov 23, 2006 at 09:44:04AM +0100, Patrick McHardy wrote:
> 
>>Jarek Poplawski wrote:
>>
>>>>+static void htb_qlen_notify(struct Qdisc *sch, unsigned long arg)
>>>>+{
>>>>+	struct htb_class *cl = (struct htb_class *)arg;
>>>>+
>>>>+	if (cl->un.leaf.q->q.qlen == 0)
>>>
>>>
>>>Probably "if (cl->prio_activity)" is needed here.
>>
>>
>>No, the function is only called for active leaf classes, which
>>always have prio_activity != 0.
> 
> 
> So this was unnecessary in htb_graft? You should know better...

In htb_graft it was necessary because the class could be
either active (qlen > 0) or inactive (qlen == 0). But since
qdisc_tree_decrease_qlen does nothing in case of a decrease
of zero the callback is only called for active classes and
the check becomes unnecessary.

