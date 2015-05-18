From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Mon, 18 May 2015 16:28:54 -0400 (EDT)
Message-ID: <20150518.162854.1116793790405432801.davem@davemloft.net>
References: <1431032664-6478-1-git-send-email-fw@strlen.de>
	<20150518.153922.1873846748456446294.davem@davemloft.net>
	<20150518200637.GB20709@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	edumazet@google.com, herbert@gondor.apana.org.au
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410AbbERU25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:28:57 -0400
In-Reply-To: <20150518200637.GB20709@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 18 May 2015 22:06:37 +0200

> So, please please re-evaluate your stance on any of the previous
> attempts or tell me how you would provide bridge netfilter with
> the means to transparently forward (refrag) reassembled skbs, without
> breaking PMTUD, in ipv4 and ipv6.

I know you really don't want to do it, but I really want to see
the "GRO'ish" idea implemented to solve all of these problems.

I know it's hard, and you're making it clear here that you'd
rather just pass an mtu argument around or duplicate the entire
ip fragmentation code base into br_netfilter to solve this problem.

But as networking maintainer I'm supposed to tell you "no" when
those kinds of proposals are being made.  Ok?

We have amazing infrastructure for dealing with oddly segmented
packets, such as skb_header_pointer().  So parsing things in
a fragmented SKB should be no problem regardless of where the
split points are.

We could have suitable interfaces for writing to packets as well,
which would be equally fast as direct access unless the SKB is
split in the middle of the object you want to write into.

The only real barrier left is overlapping fragments, and for that I'd
say just that for netfilter we can just trim the edges, just like the
ip_fragment code already does, and adjust the protocol headers
as-needed.
