From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 01 Apr 2016 22:16:32 -0400 (EDT)
Message-ID: <20160401.221632.846129753053296932.davem@davemloft.net>
References: <1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160401.152405.915323132719949585.davem@davemloft.net>
	<CAKgT0UcLvAF9gTzcaR=GZyTkM2UQ6ymDmnisjgZiG8hTE+PdLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, aduyck@mirantis.com,
	herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660AbcDBCQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 22:16:37 -0400
In-Reply-To: <CAKgT0UcLvAF9gTzcaR=GZyTkM2UQ6ymDmnisjgZiG8hTE+PdLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 1 Apr 2016 12:58:41 -0700

> RFC 6864 is pretty explicit about this, IPv4 ID used only for
> fragmentation.  https://tools.ietf.org/html/rfc6864#section-4.1
> 
> The goal with this change is to try and keep most of the existing
> behavior in tact without violating this rule?  I would think the
> sequence number should give you the ability to infer a drop in the
> case of TCP.  In the case of UDP tunnels we are now getting a bit more
> data since we were ignoring the outer IP header ID before.

When retransmits happen, the sequence numbers are the same.  But you
can then use the IP ID to see exactly what happened.  You can even
tell if multiple retransmits got reordered.

Eric's use case is extremely useful, and flat out eliminates ambiguity
when analyzing TCP traces.
