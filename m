From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 5/5] alx: add stats to ethtool
Date: Mon, 06 Jan 2014 15:11:36 +0100
Message-ID: <1389017496.5891.15.camel@jlt4.sipsolutions.net>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
	 <1388854031-24142-6-git-send-email-sd@queasysnail.net>
	 <1388998990.5891.0.camel@jlt4.sipsolutions.net>
	 <20140106105742.GA30142@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:42827 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbaAFOLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 09:11:41 -0500
In-Reply-To: <20140106105742.GA30142@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 11:57 +0100, Sabrina Dubroca wrote:
> [2014-01-06, 10:03:10] Johannes Berg wrote:
> > On Sat, 2014-01-04 at 17:47 +0100, Sabrina Dubroca wrote:
> > 
> > > +	__alx_update_hw_stats(hw);
> > > +	BUILD_BUG_ON(sizeof(hw->stats) - offsetof(struct alx_hw_stats, rx_ok) <
> > > +		     ALX_NUM_STATS * sizeof(u64));
> > 
> > I think you should make that != instead of <, otherwise you won't catch
> > all possible differences.
> 
> With a !=, BUILD_BUG_ON is triggered if a new field is added at the
> end of the structure. 

That seems reasonable, you'd want to export that field as well? Fields
that shouldn't be exported could be added before rx_ok.

> But adding a field doesn't break the code,
> though I'm not sure allowing this is useful. The offsetof (and the
> source in memcpy) also allows to add new fields at the beginning.
> 
> And the way alx_update_hw_stats is written already includes a kind of
> check that all fields are present.

I was more worried about type mismatches. That's not really a concern
with u64 since that's the largest type that really makes sense here, but
if the type of some variables changed vs. the ethtool type u64...

Maybe I'm overly worried. It seems likely nobody will ever touch this
code again :)

johannes
