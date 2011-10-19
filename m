From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 16:27:50 +0200
Message-ID: <20111019142750.GB15253@netboy.at.omicron.at>
References: <20111019115012.GA7206@netboy.at.omicron.at>
 <1319027881.3103.27.camel@edumazet-laptop>
 <1319029101.4424.36.camel@jlt3.sipsolutions.net>
 <1319029794.4424.37.camel@jlt3.sipsolutions.net>
 <1319030740.8416.14.camel@edumazet-laptop>
 <1319031348.1286.4.camel@jlt3.sipsolutions.net>
 <1319031856.8416.19.camel@edumazet-laptop>
 <1319032638.1286.7.camel@jlt3.sipsolutions.net>
 <1319033305.8416.29.camel@edumazet-laptop>
 <1319034248.1286.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43866 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942Ab1JSO1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 10:27:46 -0400
Received: by ggnb1 with SMTP id b1so1705709ggn.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 07:27:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1319034248.1286.8.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 04:24:08PM +0200, Johannes Berg wrote:
> On Wed, 2011-10-19 at 16:08 +0200, Eric Dumazet wrote:
> 
> > > Anyway, I guess you agree that the patches as-is aren't actually the
> > > right solution since we can't sock_hold() a TX skb socket reference?
> > 
> > Yes, the sock_hold() could be changed by an atomic_inc_not_zero()
> > 
> > What about doing this ?
> 
> >  		if (likely(phydev->drv->txtstamp)) {
> > +			if (!atomic_inc_not_zero(&sk->sk_refcnt))
> > +				return;
> 
> Yeah that seems like it works and just drops the timestamp in case we
> don't still have a live socket, which is perfectly fine.

Yes, I think it resolves any doubt. I will resubmit with this
solution.

Thanks,
Richard
