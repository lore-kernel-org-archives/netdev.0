From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Wed, 13 Jun 2012 02:42:25 -0700 (PDT)
Message-ID: <20120613.024225.1623724542402950589.davem@davemloft.net>
References: <20120612114440.GM27795@secunet.com>
	<20120612.133333.527780673034196147.davem@davemloft.net>
	<20120613080152.GN27795@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab2FMJma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 05:42:30 -0400
In-Reply-To: <20120613080152.GN27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 13 Jun 2012 10:01:52 +0200

> I think an application that sets IP_PMTUDISC_WANT explicitly will
> rely on the fact that the kernel does pmtu discovery. Changing
> the socket setting to IP_PMTUDISC_DONT the first time we get into
> trouble makes IP_PMTUDISC_WANT pointless for udp and raw sockets.

How so?

We are mimicking exactly what would happen if we had just created
a new routing cache entry when the application openned the socket.

There is no behavioral difference whatsoever.

We absolutely do perform PMTU discovery, the first large packet
will trigger it.  And then, as if we had lowered the PMTU in
the routing cache entry, we will stop setting DF in the packets.

Because that is how the IP_PMTUDISC_* checks work in the IP output
path in the place that decides whether to set DF or not.

> Another option would be to change the sockets default setting
> from IP_PMTUDISC_WANT to IP_PMTUDISC_DONT (at least for udp and
> raw) and do pmtu discovery if an application sets IP_PMTUDISC_WANT.

Changing defaults doesn't make the problem go away, and is also
unexpected.

I did all of my testing using the "-M" option of ping.
