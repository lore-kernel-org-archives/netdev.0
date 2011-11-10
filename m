From: David Miller <davem@davemloft.net>
Subject: Re: dst->obsolete has become pointless
Date: Wed, 09 Nov 2011 19:47:19 -0500 (EST)
Message-ID: <20111109.194719.1584771347434777010.davem@davemloft.net>
References: <1320882969.6923.29.camel@Joe-Laptop>
	<20111109.192427.661860445333469011.davem@davemloft.net>
	<1320885223.5825.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, steffen.klassert@secunet.com,
	netdev@vger.kernel.org, timo.teras@iki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933409Ab1KJArj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 19:47:39 -0500
In-Reply-To: <1320885223.5825.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Nov 2011 01:33:43 +0100

> Now some information was migrated to inetpeer, I wonder if we could not
> allocate a private dst for a socket ?

Yes, and in fact we are well equipted to support this kind of notion
exactly because we can detect route invalidity with simply serial
number comparisons.

All the necessary mechanics are there.  Simply allocate the cloned
route with DST_NOCOUNT, do not put it into any tables, and copy over
the necessary information.

Even things like __sk_dst_check() will just work transparently.

There might be some gotchas wrt. stacked IPSEC routes, but I don't
anticipate any real serious problems.
