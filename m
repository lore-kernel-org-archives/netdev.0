From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation
	with hrtimers
Date: Thu, 5 Feb 2009 07:38:32 +0000
Message-ID: <20090205073832.GA4305@ff.dom.local>
References: <200902021926.17768.denys@visp.net.lb> <200902050026.46603.denys@visp.net.lb> <20090204224929.GB2828@ami.dom.local> <200902050124.05969.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:21069 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbZBEHij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 02:38:39 -0500
Received: by fg-out-1718.google.com with SMTP id 16so64898fgg.17
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2009 23:38:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200902050124.05969.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 01:24:05AM +0200, Denys Fedoryschenko wrote:
> On Thursday 05 February 2009 00:49:29 Jarek Poplawski wrote:
> > On Thu, Feb 05, 2009 at 12:26:46AM +0200, Denys Fedoryschenko wrote:
> > ...
> >
> > > Maybe we can put note in documentation or even htb help output, that user
> > > can increase precision with hrtimers enabled, by setting HZ variable?
> >
> > Hmm... I rather meant using burst and cburst params. But hrtimers are
> > very hardware dependent, so it's hard to advise anything.
> >
> > Jarek P.
> 
> By default burst/cburst calculated depends on timer resolution, as i 
> understood, by taking 4th parameter of /proc/net/psched, which as i 
> understood - precision of hrtimer .
> 
> With hrtimers it is nanosecond resolution, precision is very high, but 
> overhead too high too. And as i understand, maybe it can be problem, that htb 
> still uses HZ variable in some cases like:
> 	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;

I think HZ doesn't matter much in this place, because if it's ever
triggered there is something really wrong and precision is lost.
Anyway, this place was changed a bit in net-next.

I guess I could misunderstand your previous question. If you mean this
previous thread, then yes, IMHO CONFIG_HZ should matter for precision
(especially places where similar loops use all such jiffies in "normal"
situations). On the other hand, maybe I'm wrong, but using HZ 1000
with HIGH_RES_TIMERS looks quite obvious to me...

Jarek P.
