From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] udp: Flow dissection for tunnels
Date: Thu, 13 Oct 2016 15:17:00 -0400 (EDT)
Message-ID: <20161013.151700.1071876162706356206.davem@davemloft.net>
References: <20161012232547.2383961-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37058 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755710AbcJMTSV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 15:18:21 -0400
In-Reply-To: <20161012232547.2383961-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 12 Oct 2016 16:25:42 -0700

> Since performing a UDP lookup on every packet might be expensive I
> added a static key check to bypass the lookup if there are no
> sockets with flow_dissect set. I should mention that doing the
> lookup wasn't particularly a big hit anyway.

I think this new static key is unnecessary, as it is equivalent
to: (udp_encap_needed + udpv6_encap_needed)

This socket lookup is very heavy handed, and I realize that you
need this because we no longer store the encapsulation socket in
skb->sk these days.

Can you talk about the various code paths that lead into the
flow dissector and why the UDP socket lookup is needed?  Maybe
we can propagate it another way, at least on TX.

Thanks.
