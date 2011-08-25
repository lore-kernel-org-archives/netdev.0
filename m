From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 13:14:38 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1108251307460.21709@wel-95.cs.helsinki.fi>
References: <1314226834.6797.5.camel@edumazet-laptop>  <1314229310-8074-1-git-send-email-hagen@jauu.net>  <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>  <1314250134.6797.24.camel@edumazet-laptop>  <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>
  <1314260805.2387.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E560BFD.5020301@arndnet.de>  <1314263389.2387.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E5619DA.6070902@arndnet.de> <1314266562.2387.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1510937174-1314267223=:21709"
Cc: Arnd Hannemann <arnd@arndnet.de>,
	Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>,
	Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46249 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab1HYKOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 06:14:40 -0400
In-Reply-To: <1314266562.2387.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-ID: <alpine.DEB.2.00.1108251313510.21709@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1510937174-1314267223=:21709
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1108251313511.21709@wel-95.cs.helsinki.fi>

On Thu, 25 Aug 2011, Eric Dumazet wrote:

> Le jeudi 25 août 2011 à 11:46 +0200, Arnd Hannemann a écrit :
> > Hi Eric,
> > 
> > Am 25.08.2011 11:09, schrieb Eric Dumazet:
> 
> > > Maybe we should refine the thing a bit, to not reverse backoff unless
> > > rto is > some_threshold.
> > > 
> > > Say 10s being the value, that would give at most 92 tries.
> > 
> > I personally think that 10s would be too large and eliminate the benefit of the
> > algorithm, so I would prefer a different solution.
> > 
> > In case of one bulk data TCP session, which was transmitting hundreds of packets/s
> > before the connectivity disruption those worst case rate of 5 packet/s really
> > seems conservative enough.
> > 
> > However in case of a lot of idle connections, which were transmitting only
> > a number of packets per minute. We might increase the rate drastically for
> > a certain period until it throttles down. You say that we have a problem here
> > correct?
> > 
> > Do you think it would be possible without much hassle to use a kind of 
> > "global" rate limiting only for these probe packets of a TCP connection?
> >
> > > I mean, what is the gain to be able to restart a frozen TCP session with
> > > a 1sec latency instead of 10s if it was blocked more than 60 seconds ?
> > 
> > I'm afraid it does a lot, especially in highly dynamic environments. You
> > don't have just the additional latency, you may actually miss the full
> > period where connectivity was there, and then just retransmit into the next
> > connectivity disrupted period.
> 
> Problem with this is that with short and synchronized timers, all
> sessions will flood at the same time and you'll get congestion this
> time.
>
> The reason for exponential backoff is also to smooth the restarts of
> sessions, because timers are randomized.

But if you get a real congestion the system will self-regulate using 
exponential backoffs due to lack of ICMPs for some of the connections?


-- 
 i.
--8323329-1510937174-1314267223=:21709--
