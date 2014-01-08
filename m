From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/5] tcp: metrics: Add source-address to
 tcp-metrics
Date: Wed, 08 Jan 2014 15:13:46 -0800
Message-ID: <1389222826.31367.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1389193559-16756-3-git-send-email-christoph.paasch@uclouvain.be>
	 <1389203751.26646.100.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140108224344.GE4700@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:56444 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757101AbaAHXNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 18:13:35 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so2205529pbc.38
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 15:13:35 -0800 (PST)
In-Reply-To: <20140108224344.GE4700@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-08 at 23:43 +0100, Christoph Paasch wrote:
> Hello Eric,
> 
> On 08/01/14 - 09:55:51, Eric Dumazet wrote:
> > On Wed, 2014-01-08 at 16:05 +0100, Christoph Paasch wrote:
> > > We add the source-address to the tcp-metrics, so that different metrics
> > > will be used per source/destination-pair. We use the destination-hash to
> > > store the metric inside the hash-table. That way, deleting and dumping
> > > via "ip tcp_metrics" is easy.
> > 
> > Note that this has the following problem :
> > 
> > Some applications use a set of source IP addresses to overcome the 64K
> > port limitation.
> 
> Ok, did not know about that.
> 
> > tcp_metrics uses a hard-coded TCP_METRICS_RECLAIM_DEPTH value of 5,
> > meaning that cache wont be able to store more than 5 source IP addresses
> > (reaching one particular remote IP).
> 
> Maybe we could do something like the below (yet untested). That way we allow
> up to 32 entries with the same destination but different source and still
> only 5 with different destinations.
> 
> I guess 32 * 64K connections is enough. :)
> We could also make TCP_METRICS_RECLAIM_DEPTH(_DST) a tunable.

Well, not sure if this is a problem anyway, and if we want extra
complexity for this rare use case, considering tcp metrics for
high number of flows sharing a common path is unlikely to be useful
(with exception of Fast Open, but again it must be rare)
