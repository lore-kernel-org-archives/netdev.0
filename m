From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next, V3 0/2] net: force refragmentation for DF
 reassembed skbs
Date: Fri, 22 May 2015 15:03:10 -0400 (EDT)
Message-ID: <20150522.150310.2248217318352290500.davem@davemloft.net>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756720AbbEVTDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 15:03:13 -0400
In-Reply-To: <1432305171-21932-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 22 May 2015 16:32:49 +0200

> IP (ttl 64, id 12345, offset 0, flags [+, DF], proto UDP (17), length 1204)
>     192.168.7.1.42 > 10.23.42.2.42: UDP, length 1400
> IP (ttl 64, id 12345, offset 1184, flags [DF], proto UDP (17), length 244)
>     192.168.7.1 > 10.23.42.2: ip-proto-17

I almost consider a fragment with DF set an oxymoron.

How does this happen?

DF is a mechanism for PMTU discovery.  Therefore it is the end nodes
which set DF on packets before fragmentation can even take place.
Since DF is set initially, the logical consequence is that the packet
cannot be legally fragmented along the way.

Are tunnels doing something to create this situation?
