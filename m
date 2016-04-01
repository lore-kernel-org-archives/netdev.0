From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 01 Apr 2016 15:24:05 -0400 (EDT)
Message-ID: <20160401.152405.915323132719949585.davem@davemloft.net>
References: <20160401175741.13882.24175.stgit@localhost.localdomain>
	<20160401180531.13882.44793.stgit@localhost.localdomain>
	<1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, herbert@gondor.apana.org.au,
	tom@herbertland.com, jesse@kernel.org, alexander.duyck@gmail.com,
	edumazet@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbcDATYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 15:24:07 -0400
In-Reply-To: <1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 Apr 2016 11:49:03 -0700

> For example, TCP stack tracks per socket ID generation, even if it
> sends DF=1 frames. Damn useful for tcpdump analysis and drop
> inference.

Thanks for mentioning this, I never considered this use case.

> With your change, the resulting GRO packet would propagate the ID of
> first frag. Most GSO/GSO engines will then provide a ID sequence,
> which might not match original packets.
> 
> I do not particularly care, but it is worth mentioning that GRO+TSO
> would not be idempotent anymore.

Our eventual plan was to start emitting zero in the ID field for
outgoing TCP datagrams with DF set, since the issue that caused us to
generate incrementing IDs in the first place (buggy Microsoft SLHC
compression) we decided is not relevant and important enough to
accommodate any more.

So outside of your TCP behavior analysis case, there isn't a
compelling argument to keeping that code around any more, rather than
just put zero in the ID field.

I suppose we could keep the counter code around and allow it to be
enabled using a sysctl or socket option, but how strongly do you
really feel about this?
