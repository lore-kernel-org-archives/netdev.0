From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Thu, 28 Jun 2012 19:17:31 +0100
Message-ID: <1340907451.2577.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F6B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Tom Parkin <tparkin@katalix.com>, <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7192 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751677Ab2F1SRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 14:17:40 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F6B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 09:46 +0100, David Laight wrote:
> > [1] : LLTX drivers case 
> >    since ndo_start_xmit() can be run concurrently by many cpus, safely
> > updating an "unsigned long" requires additional hassle :
> > 
> >    1) Use of a spinlock to protect the update.
> >    2) Use atomic_long_t instead of "unsigned long"
> >    3) Use percpu data
> 
> 4) These are statistics so it shouldn't really matter if
>    they are out by a small number.

You might be surprised just how much end users care about statistics.

>    So the errors
>    introduced by unlocked updates can probably be ignored.
>    So just use 'unsigned long'.

This can result in statistics being decremented in case of a race.  That
should never be allowed to happen.

Ben.

>    Might be worth putting in gcc barriers so that the
>    load and store instructions aren't separated too far.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
