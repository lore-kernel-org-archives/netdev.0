From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] tcp: don't allow syn packets without timestamps to pass
 tcp_tw_recycle logic
Date: Tue, 12 Aug 2014 10:03:53 +0200
Message-ID: <1407830633.3312295.151750837.3F816F09@webmail.messagingengine.com>
References: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
 <1407807170.10122.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:49939 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754215AbaHLID4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 04:03:56 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway1.nyi.internal (Postfix) with ESMTP id 5781F23A02
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 04:03:53 -0400 (EDT)
In-Reply-To: <1407807170.10122.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2014, at 03:32, Eric Dumazet wrote:
> On Tue, 2014-08-12 at 02:21 +0200, Hannes Frederic Sowa wrote:
> > If tw_recycle is enabled, non-timestamped SYN packets could get past
> > the tw_recycle check and create a new connection. This is dangerous
> > as we cannot verify that segments from an old connection won't be
> > accepted by the new one in tcp_validate_incoming because of the missing
> > timestamps. Note that Windows seems to have timestamps disabled by
> > default. Thus this broken situation could easily arise by a Linux and
> > Windows box sharing one IP address and talking to a tcp_tw_recycle
> > enabled server.
> > 
> > We don't change the behavior regarding how many SYNs we queue up from
> > non timestamping hosts (the second tcp_peer_is_proven check), because the
> > second call to tcp_peer_is_proven does not use the new boolean timestamp
> > argument at all because PAWS check is disabled.
> > 
> > Cc: Florian Westphal <fw@strlen.de>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> 
> Not sure what you try to achieve here.
>
> tw_recycle can only be used in very controlled environment, no NAT, and
> all hosts using timestamps.
> 
> If using NAT, then tw_recycle can not be used, even if all hosts are
> linux boxes with timestamps enabled.

Mostly me being pessimistic. ;)

I noticed that tw_recycle nonetheless tries to cope with the fact that
sometimes non-timestamped SYNs arrive. E.g. the scheduling of the
time-wait timeout only happens for only RTO in case the host saw
timestamps on the connection, otherwise normal TIMEWAIT_MSL applies.

So I wanted to stop "illegal" connection setups and trade that against
possible data corruption in case someone switches this knob on in a not
controlled environment.

Bye,
Hannes
