From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Tue, 05 Apr 2016 19:45:17 -0400 (EDT)
Message-ID: <20160405.194517.431351466693438399.davem@davemloft.net>
References: <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
	<20160405043209.GA9822@gondor.apana.org.au>
	<5703D4C5.9060305@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, alexander.duyck@gmail.com,
	aduyck@mirantis.com, tom@herbertland.com, jesse@kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088AbcDEXpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 19:45:20 -0400
In-Reply-To: <5703D4C5.9060305@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 5 Apr 2016 16:07:49 +0100

> On the gripping hand, I feel like GRO+TSO is the wrong model for
> speeding up forwarding/routing workloads.  Instead we should be
> looking into having lists of SKBs traverse the stack together,
> splitting the list whenever e.g. the destination changes.

"Destination" is a very complicated beast.  It's not just a
destination IP address.

It's not even just a full saddr/daddr/TOS triplet.

Packets can be forwarded around based upon any key whatsoever in the
headers.  Netfilter can mangle them based upon arbitrary bits in the
packet, as can the packet scheduler classifier actions.

It's therefore not profitable to try this at all, it's completely
pointless unless all the keys match up exactly.

This is why GRO _is_ the proper model to speed this stuff and do
bulk processing, because it still presents a full "packet" to all
of these layers to mangle, rewrite, route, and do whatever else
however they like.
