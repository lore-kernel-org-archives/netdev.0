From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Tue, 17 Jul 2007 14:01:48 +0200
Message-ID: <469CAFAC.9010301@trash.net>
References: <20070712104641.GB1708@ff.dom.local> <1184240842.3477.110.camel@ranko-fc2.spidernet.net> <46961970.7080209@trash.net> <1184262525.3477.135.camel@ranko-fc2.spidernet.net> <20070713121733.GB3282@ff.dom.local> <1184329602.16732.16.camel@ranko-fc2.spidernet.net> <20070713134231.GC3282@ff.dom.local> <20070716070032.GA1871@ff.dom.local> <469B6CA4.9030205@trash.net> <1184607905.18564.50.camel@ranko-fc2.spidernet.net> <20070717120436.GC2049@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ranko Zivojnovic <ranko@spidernet.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42846 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754877AbXGQMBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 08:01:52 -0400
In-Reply-To: <20070717120436.GC2049@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> This patch looks fine, but while checking for this lock I've found
> another strange thing: for actions tcfc_stats_lock is used here, which
> is equivalent to tcfc_lock; so, in gen_kill_estimator we get this lock
> sometimes after dev->queue_lock; this order is also possible during
> tc_classify if actions are used; on the other hand act_mirred calls
> dev_queue_xmit under this lock, so dev->queue_lock is taken in another
> order. I hope it's with different devs, and there is no real deadlock
> possible, but this all is a bit queer...


It *should* be a different device, but AFAIK nothing enforces this.
There are quite a few possible deadlocks with TC actions, mid-term
things like the mirred action need to be redesigned to inject packet
from a different context.

> I don't know actions enough, but it seems, if it's possible that they
> are always run only from tc_classify, with dev->queue_lock, maybe it
> would be simpler to use this lock for actions' stats with
> gen_estimator too.


The same action can be shared between devices, so they need seperate
locks.
