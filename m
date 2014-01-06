From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v2 5/5] alx: add stats to ethtool
Date: Mon, 6 Jan 2014 15:56:29 +0100
Message-ID: <20140106145629.GA7886@kria>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
 <1388854031-24142-6-git-send-email-sd@queasysnail.net>
 <1388998990.5891.0.camel@jlt4.sipsolutions.net>
 <20140106105742.GA30142@kria>
 <1389017496.5891.15.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:46962 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580AbaAFO4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 09:56:46 -0500
Content-Disposition: inline
In-Reply-To: <1389017496.5891.15.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-01-06, 15:11:36 +0100, Johannes Berg wrote:
> On Mon, 2014-01-06 at 11:57 +0100, Sabrina Dubroca wrote:
> > [2014-01-06, 10:03:10] Johannes Berg wrote:
> > > On Sat, 2014-01-04 at 17:47 +0100, Sabrina Dubroca wrote:
> > > 
> > > > +	__alx_update_hw_stats(hw);
> > > > +	BUILD_BUG_ON(sizeof(hw->stats) - offsetof(struct alx_hw_stats, rx_ok) <
> > > > +		     ALX_NUM_STATS * sizeof(u64));
> > > 
> > > I think you should make that != instead of <, otherwise you won't catch
> > > all possible differences.
> > 
> > With a !=, BUILD_BUG_ON is triggered if a new field is added at the
> > end of the structure. 
> 
> That seems reasonable, you'd want to export that field as well? Fields
> that shouldn't be exported could be added before rx_ok.

I don't have anything else to add here, I'm just considering what
others might want to do. Maybe overthinking. But, yeah, that's the idea.
(and fields added to the end of the struct but that don't have a
description in alx_gstrings_stats are ignored)

> > But adding a field doesn't break the code,
> > though I'm not sure allowing this is useful. The offsetof (and the
> > source in memcpy) also allows to add new fields at the beginning.
> > 
> > And the way alx_update_hw_stats is written already includes a kind of
> > check that all fields are present.
> 
> I was more worried about type mismatches. That's not really a concern
> with u64 since that's the largest type that really makes sense here, but
> if the type of some variables changed vs. the ethtool type u64...

Add "all stats fields must be u64" to the comment before the struct?


> Maybe I'm overly worried. It seems likely nobody will ever touch this
> code again :)

:)

-- 
Sabrina
