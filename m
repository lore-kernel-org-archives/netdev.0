From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Mon, 16 Jul 2007 09:00:32 +0200
Message-ID: <20070716070032.GA1871@ff.dom.local>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net> <20070712073746.GA1708@ff.dom.local> <1184231903.3477.65.camel@ranko-fc2.spidernet.net> <20070712104641.GB1708@ff.dom.local> <1184240842.3477.110.camel@ranko-fc2.spidernet.net> <46961970.7080209@trash.net> <1184262525.3477.135.camel@ranko-fc2.spidernet.net> <20070713121733.GB3282@ff.dom.local> <1184329602.16732.16.camel@ranko-fc2.spidernet.net> <20070713134231.GC3282@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:53713 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754203AbXGPGvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 02:51:40 -0400
Content-Disposition: inline
In-Reply-To: <20070713134231.GC3282@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 03:42:31PM +0200, Jarek Poplawski wrote:
...
> On Fri, Jul 13, 2007 at 03:26:42PM +0300, Ranko Zivojnovic wrote:
> I've been a bit tight on time today, and only now I see that maybe
> you have done too much. Of course, you can do it your way, but I
> think it should be easier not change too much at once, so if possible
> only include structs bstats and rate_est into struct gen_estimator
> and do otherwise in these few sch_'s and act_'s which use this plus
> all acceses and allocs changed appropriately. So it should be only 6
> or 7 files affected. It seems no changes about gen_stats are necessary
> now (next patch?).

Alas, I was wrong. This idea really needs to change all these files
plus even more! If I could've foreseen this...

There is probably quite easy way to get rid of this one race only
by e.g. replacing *bstats field with NULL in gen_kill_estimator,
and check for this in est_timer just after taking a lock.

The gain from an api change would be mainly faster gen_kill_
and gen_replace_estimator. But, on the other hand, you have it
almost done. Ranko, I think these changes need opinion of more
maintainers as soon as possible - after all they could have some
objections; IMHO at least: Jamal Hadi Salim, Thomas Graf (authors
plus act_), Stephen Hemminger (sch_netem) and Jiri Benc
(net/mac80211).

I also have some suggestions, but maybe it would be better to do
them on a current version (the main is about this *stats_lock - 
you probably misunderstood Patrick - but I hope you found it
yourself).

Regards,
Jarek P.
