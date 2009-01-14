From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 15:28:03 +0100
Message-ID: <1231943283.14825.14.camel@laptop>
References: <20081010090426.GA6054@ff.dom.local>
	 <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop>
	 <200901141505.46929.denys@visp.net.lb> <20090114131257.GC6117@ff.dom.local>
	 <1231938929.14825.6.camel@laptop> <20090114132603.GD6117@ff.dom.local>
	 <1231939946.14825.9.camel@laptop>  <20090114141311.GA6643@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Chris Caputo <ccaputo@alt.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45456 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755378AbZANO2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 09:28:09 -0500
In-Reply-To: <20090114141311.GA6643@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 14:13 +0000, Jarek Poplawski wrote:
> On Wed, Jan 14, 2009 at 02:32:26PM +0100, Peter Zijlstra wrote:
> > On Wed, 2009-01-14 at 13:26 +0000, Jarek Poplawski wrote:
> > 
> > > OK, I hope Denys can apply more, but what about others? Without any
> > > patches the hole seems to be much bigger.
> > 
> > OK, I read most of this thread on netdev, but didn't find a clear clue
> > on the specific hrtimer insertion race.
> 
> There is something at the beginning of this thread, plus earlier
> threads mostly with Denys as sender, and "htb bug" in the subject.
> 
> > 
> > Do you have any clear ideas or should I poke at the htb/hrtimer code a
> > little?
> > 
> 
> ....And htb code is htb_dequeue(): qdisc_watchdog_schedule().

Right, found all that...

Can't spot anything obviously wrong though.. hrtimer_start*() does
remove_hrtimer() which checks STATE_ENQUEUED, STATE_PENDING and pulls it
off the relevant list before it continues the enqueue.

However a loop in enqueue_hrtimer() would suggest a corrupted RB-tree,
but I cannot find an RB-op that doesn't hold base-lock.

Hohumm..

