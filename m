From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 23:22:35 -0500 (EST)
Message-ID: <20130122.232235.643904201225800004.davem@davemloft.net>
References: <20130122.194143.1205292712415183747.davem@davemloft.net>
	<1358903293.12374.492.camel@edumazet-glaptop>
	<20130122.204629.607263597214211092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093Ab3AWEWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 23:22:37 -0500
In-Reply-To: <20130122.204629.607263597214211092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 22 Jan 2013 20:46:29 -0500 (EST)

> We can't emit bogus checksums on the wire when this is completely
> under our control.

BTW consider a legitimate use case where an application has a shared
memory page between threads that keeps track of statistic counters,
and it uses sendfile() over an fd backing that mmap()'d area to
send the statistics out remotely over TCP.

That's completely legitimate.

As is an application constantly overwriting a page in the filesystem
page cache, and another app doing sendfile() over TCP from that
area.

In such a situation everyone of your magic retransmits will have a
bad checksum too.

You can't say that this behavior is anything other than broken, and
I don't want to be responsible for a system that's doing broken
things like that.

If your GSO over GRE tunnels stuff fundamentally depends upon this
magic retransmit fantasy working, then yes we have to disable it
completely.
