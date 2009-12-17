From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() ->
 cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 22:58:23 +0100
Message-ID: <20091217215823.GA3491@ami.dom.local>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
 <20091217074930.GA6779@ff.dom.local>
 <20091217133644.GD8654@ff.dom.local>
 <1261060259.10356.112.camel@johannes.local>
 <11218.1261066373@death.nxdomain.ibm.com>
 <20091217184017.GA2578@ami.dom.local>
 <97949e3e0912171049x607ded5cgf3b696a5d89129ba@mail.gmail.com>
 <29926.1261078662@death.nxdomain.ibm.com>
 <20091217205617.GB2578@ami.dom.local>
 <9587.1261086029@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Laurent Chavey <chavey@google.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:42295 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762686AbZLQV7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 16:59:00 -0500
Received: by fxm21 with SMTP id 21so2340338fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 13:58:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <9587.1261086029@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 01:40:29PM -0800, Jay Vosburgh wrote:
> 	A less evil alternative would be to punt and reschedule the work
> if the rtnl_trylock failed, e.g.,
> 
> 	if (bond_miimon_inspect(bond)) {
> 		read_unlock(&bond->lock);
> 		if (!rtnl_trylock()) {
> 			queue_work(...);
> 			return;
> 		}
> 
> 		read_lock(&bond->lock);
> 
> 		bond_miimon_commit(bond);
> 		[...]
> 
> 	I'm not sure what the usual contention level on rtnl is (and,
> therefore, how often this will punt for the normal case that's not the
> race we're trying to avoid here).

Even if there is not much contention there is usually a lot of work
inside, so this looks most reasonable to me.

Jarek P.
