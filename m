From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] pkt_sched: Control group classifier
Date: Fri, 17 Oct 2008 20:23:12 +0200
Message-ID: <20081017182312.GE20815@postel.suug.ch>
References: <20081013155715.GZ20815@postel.suug.ch> <873aixksf0.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39625 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567AbYJQSWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2008 14:22:52 -0400
Content-Disposition: inline
In-Reply-To: <873aixksf0.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Andi Kleen <andi@firstfloor.org> 2008-10-16 07:41
> Thomas Graf <tgraf@suug.ch> writes:
> >
> > The principle of the classifier is to directly access the
> > task_struct via get_current(). In order for this to work,
> > classification requests from softirqs must be ignored.
> 
> You mean the classifier just wants to know if it runs
> as a softirq?

Yes, exactly.

> > This is
> > not a problem because the vast majority of packets in softirq
> > context are not assigned to a task anyway. For this to work, a
> > mechanism is needed to trace softirq context.
> > The only existing
> > way to do so is to use the TRACE_IRQFLAGS feature, unfortunately
> 
> Does't softirq_count() > 0 check that?

softirq_count() simply counts the levels of bh disable.
