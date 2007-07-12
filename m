From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Thu, 12 Jul 2007 12:40:00 +0300
Message-ID: <1184233200.3477.71.camel@ranko-fc2.spidernet.net>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
	 <20070712073746.GA1708@ff.dom.local>
	 <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:30786 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755749AbXGLJlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 05:41:04 -0400
In-Reply-To: <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-12 at 12:18 +0300, Ranko Zivojnovic wrote:
> > 
> > I've done a bit of mess last time, so maybe it was forgotten, but I
> > still think this kind of race is possible:
> > 
> > - gen_kill_estimator is called during qdisc_destroy under
> >   dev->queue_lock,
> > - est_timer is running and waiting on this lock just on the
> >   list entry of the destroyed class,
> > - gen_kill_estimator kills the entry and returns,
> > - in xxx_destroy_class kfree(cl) is done etc.,
> > - est_timer gets the lock and does nbytes = e->bstats->bytes or
> >   e->rate_est-bps = ... with freed memory.
> 
> Unfortunately I cannot say for sure that _currently_ anything really bad
> can happen here... someone with better knowledge will have to confirm
> this - Patrick?
> 

Oops - just saw it - and you even mention it up there: 

e->rate_est->bps = ...
          ^^^^
>
> Will have a new patch soon.
>

R.

