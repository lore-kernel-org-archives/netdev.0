From: David Miller <davem@davemloft.net>
Subject: Re: [v3] net: ipv6: fallback to full lookup if table lookup is
 unsuitable
Date: Tue, 20 Sep 2016 03:29:10 -0400 (EDT)
Message-ID: <20160920.032910.512829220195292472.davem@davemloft.net>
References: <8bce7180-e4c2-808c-20e0-0bd9634b8fc2@cumulusnetworks.com>
        <20160918154607.5474-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: vincent@bernat.im
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbcITH3N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 03:29:13 -0400
In-Reply-To: <20160918154607.5474-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <vincent@bernat.im>
Date: Sun, 18 Sep 2016 17:46:07 +0200

> Commit 8c14586fc320 ("net: ipv6: Use passed in table for nexthop
> lookups") introduced a regression: insertion of an IPv6 route in a table
> not containing the appropriate connected route for the gateway but which
> contained a non-connected route (like a default gateway) fails while it
> was previously working:
> 
>     $ ip link add eth0 type dummy
>     $ ip link set up dev eth0
>     $ ip addr add 2001:db8::1/64 dev eth0
>     $ ip route add ::/0 via 2001:db8::5 dev eth0 table 20
>     $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
>     RTNETLINK answers: No route to host
>     $ ip -6 route show table 20
>     default via 2001:db8::5 dev eth0  metric 1024  pref medium
> 
> After this patch, we get:
> 
>     $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
>     $ ip -6 route show table 20
>     2001:db8:cafe::1 via 2001:db8::6 dev eth0  metric 1024  pref medium
>     default via 2001:db8::5 dev eth0  metric 1024  pref medium
> 
> Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
> Signed-off-by: Vincent Bernat <vincent@bernat.im>

Applied and queued up for -stable, thanks.
