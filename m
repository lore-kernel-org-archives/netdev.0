From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Make tcp-metrics source-address aware
Date: Sun, 15 Dec 2013 20:45:27 -0500 (EST)
Message-ID: <20131215.204527.2114963340287148861.davem@davemloft.net>
References: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ja@ssi.bg
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab3LPBp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 20:45:29 -0500
In-Reply-To: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Sun, 15 Dec 2013 13:10:40 +0100

> Currently tcp-metrics only stores per-destination addresses. This brings
> problems, when a host has multiple interfaces (e.g., a smartphone having
> WiFi/3G):

So, at what point will we stop adding keys to tcp-metrics?

Several things can influence the network path, 'saddr' is just an
arbitrary and obvious one.

Even the TCP port numbers, via IPSEC rules, can make the packets go
over a completely different route with wildly different
characteristics, resulting in the same exact problem you say we need
to add 'saddr' for.

I'm not against adding 'saddr' to the metrics key, I just want to
know decide now (rather than later) far we need to go and implement
that fully rather than inching along one step at a time to the
same final result.

If the answer is "yes we must consider all potential keys" then we
will essentially have something approximating a single tcp-metrics
entry for every unique TCP connection ever openned because the source
and destination ports will be taken into account.

We won't be sharing metrics information at all at that point, so we
might as well remove it.

Arguably, when the metrics were in the routes, these details we hidden
away from us and we used fine grained metrics information when it
actually mattered.  If there were no IPSEC rules being used, we
wouldn't use keys detailed down to the port numbers.

However the routing cache always, at the very least, got us metrics
which were fine grained down to saddr/daddr/TOS/MARK etc.
