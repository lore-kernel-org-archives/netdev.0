From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/5] alx: add alx_get_stats operation
Date: Thu, 2 Jan 2014 16:25:06 +0000
Message-ID: <1388679906.9947.1.camel@bwh-desktop.uk.level5networks.com>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	 <1388619628-3373-5-git-send-email-sd@queasysnail.net>
	 <20140101.222702.1562824655053158808.davem@davemloft.net>
	 <1388663813.22017.12.camel@deadeye.wl.decadent.org.uk>
	 <20140102160531.GA25216@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <johannes@sipsolutions.net>,
	<netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28868 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbaABQZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 11:25:15 -0500
In-Reply-To: <20140102160531.GA25216@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 17:05 +0100, Sabrina Dubroca wrote:
> [2014-01-02, 11:56:53] Ben Hutchings wrote:
> > On Wed, 2014-01-01 at 22:27 -0500, David Miller wrote:
> > > From: Sabrina Dubroca <sd@queasysnail.net>
> > > Date: Thu,  2 Jan 2014 00:40:27 +0100
> > > 
> > > > +	spin_lock(&alx->stats_lock);
> > > > +
> > > > +	__alx_update_hw_stats(&alx->hw);
> > > 
> > > Please use something like the linux/u64_stats_sync.h stuff rather
> > > than spin locking.
> > 
> > I don't think that'sa useful, as we can have multiple writers
> > (concurrent calls to get_stats).  And there is really no harm in using a
> > spinlock to serialise get_stats calls.  The u64_stats API is good for
> > statistics updated from the data path.
> 
> I've read the comments in linux/u64_stats_sync.h, which mentions the
> need for exclusive access to the data. I've looked at other drivers
> (broadcom/b44.c, nvidia/forcedeth.c) that use the u64_stats functions
> to get stats from hardware, and they use a spin_lock around the update
> code. The other drivers that I've looked at and that use u64_stats
> have software stats that they update on rx/tx, so I think the
> situation is a bit different.
> 
> 
> For now I've added u64_stats and modified the functions this way:
[...]

You could do that but I think your original version was fine.  Of course
it is David's decision in the end.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
