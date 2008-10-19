From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] pkt_sched: Control group classifier
Date: Sun, 19 Oct 2008 19:00:33 +0200
Message-ID: <20081019170032.GG20815@postel.suug.ch>
References: <20081013155715.GZ20815@postel.suug.ch> <873aixksf0.fsf@basil.nowhere.org> <20081017182312.GE20815@postel.suug.ch> <20081017183221.GA12825@one.firstfloor.org> <20081017200916.GF20815@postel.suug.ch> <20081018053810.GC12825@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50696 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475AbYJSRAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Oct 2008 13:00:12 -0400
Content-Disposition: inline
In-Reply-To: <20081018053810.GC12825@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Andi Kleen <andi@firstfloor.org> 2008-10-18 07:38
> On Fri, Oct 17, 2008 at 10:09:16PM +0200, Thomas Graf wrote:
> > * Andi Kleen <andi@firstfloor.org> 2008-10-17 20:32
> > > > softirq_count() simply counts the levels of bh disable.
> > > 
> > > softirqs always have bh disabled.  So it's always true inside them.
> > > And you should know what _bh locks you hold.
> > 
> > I actually tried "softirq_count() == SOFTIRQ_OFFSET" to see if the
> 
> softirq_count() > 0 should work.

No, it doesn't. User context calls to dev_queue_xmit() will also
disable bh and thus softirq_count() will always be > 0.
