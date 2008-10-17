From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] pkt_sched: Control group classifier
Date: Fri, 17 Oct 2008 22:09:16 +0200
Message-ID: <20081017200916.GF20815@postel.suug.ch>
References: <20081013155715.GZ20815@postel.suug.ch> <873aixksf0.fsf@basil.nowhere.org> <20081017182312.GE20815@postel.suug.ch> <20081017183221.GA12825@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42090 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754939AbYJQUI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2008 16:08:56 -0400
Content-Disposition: inline
In-Reply-To: <20081017183221.GA12825@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Andi Kleen <andi@firstfloor.org> 2008-10-17 20:32
> > softirq_count() simply counts the levels of bh disable.
> 
> softirqs always have bh disabled.  So it's always true inside them.
> And you should know what _bh locks you hold.

I actually tried "softirq_count() == SOFTIRQ_OFFSET" to see if the
call is made form user context. It works pretty well because all
callers of dev_queue_xmit() are required to disable bh. Nevertheless
I think it's quite fragile. If a dev_queue_xmit() caller from softirq
does not disable bh explicitely on its own but instead relies on
do_softirq() to have disabled bh already, the softirq count of such
a call may be equal to the one of a user context call to dev_queue_xmit().

I found explicitely counting softirq_enter() to be more reliable
without having much of a performance impact. I'm happy with both
solutions though.
