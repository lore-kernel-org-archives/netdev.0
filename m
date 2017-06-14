From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: don't global ICMP rate limit packets
 originating from loopback
Date: Wed, 14 Jun 2017 15:34:27 -0400 (EDT)
Message-ID: <20170614.153427.2166855120464478061.davem@davemloft.net>
References: <149743965710.19877.13901728209731997446.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fweimer@redhat.com, hjl.tools@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54504 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbdFNTeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:34:31 -0400
In-Reply-To: <149743965710.19877.13901728209731997446.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 14 Jun 2017 13:27:37 +0200

> Florian Weimer seems to have a glibc test-case which requires that
> loopback interfaces does not get ICMP ratelimited.  This was broken by
> commit c0303efeab73 ("net: reduce cycles spend on ICMP replies that
> gets rate limited").
> 
> An ICMP response will usually be routed back-out the same incoming
> interface.  Thus, take advantage of this and skip global ICMP
> ratelimit when the incoming device is loopback.  In the unlikely event
> that the outgoing it not loopback, due to strange routing policy
> rules, ICMP rate limiting still works via peer ratelimiting via
> icmpv4_xrlim_allow().  Thus, we should still comply with RFC1812
> (section 4.3.2.8 "Rate Limiting").
> 
> This seems to fix the reproducer given by Florian.  While still
> avoiding to perform expensive and unneeded outgoing route lookup for
> rate limited packets (in the non-loopback case).
> 
> Fixes: c0303efeab73 ("net: reduce cycles spend on ICMP replies that gets rate limited")
> Reported-by: Florian Weimer <fweimer@redhat.com>
> Reported-by: "H.J. Lu" <hjl.tools@gmail.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied and queued up for -stable, thanks Jesper.
