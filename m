From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/5] alx: add alx_get_stats operation
Date: Thu, 2 Jan 2014 11:56:53 +0000
Message-ID: <1388663813.22017.12.camel@deadeye.wl.decadent.org.uk>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	 <1388619628-3373-5-git-send-email-sd@queasysnail.net>
	 <20140101.222702.1562824655053158808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <sd@queasysnail.net>, <johannes@sipsolutions.net>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22084 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaABL44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 06:56:56 -0500
In-Reply-To: <20140101.222702.1562824655053158808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-01 at 22:27 -0500, David Miller wrote:
> From: Sabrina Dubroca <sd@queasysnail.net>
> Date: Thu,  2 Jan 2014 00:40:27 +0100
> 
> > +	spin_lock(&alx->stats_lock);
> > +
> > +	__alx_update_hw_stats(&alx->hw);
> 
> Please use something like the linux/u64_stats_sync.h stuff rather
> than spin locking.

I don't think that'sa useful, as we can have multiple writers
(concurrent calls to get_stats).  And there is really no harm in using a
spinlock to serialise get_stats calls.  The u64_stats API is good for
statistics updated from the data path.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
