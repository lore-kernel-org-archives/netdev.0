From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix TCP early demux
Date: Fri, 27 Jul 2012 16:00:01 -0700 (PDT)
Message-ID: <20120727.160001.1267518985220537042.davem@davemloft.net>
References: <1343406220.2626.13092.camel@edumazet-glaptop>
	<20120727.134713.1437322148321890583.davem@davemloft.net>
	<1343424873.2626.13112.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358Ab2G0XAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 19:00:05 -0400
In-Reply-To: <1343424873.2626.13112.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Jul 2012 23:34:33 +0200

> I wonder why cookie is not stored in dst, and must be stored outside
> of it ?

Because in ipv6, cloned routes are never invalidated on a route
insertion or deletion.  We keep them around.

The fn_sernum tracks path reachability, rather than validation of
dsts.

So when we delete or insert a new ipv6 route, we update the serial
number of all the FIB nodes on the way down to the insert/delete
point.

If, afterwards, we can still reach a route cloned from one of those
entries successfully.  It is still valid.

If we were to store the serial number on the dst, it would invalidate
the cloned route, which the ipv6 code is largely not designed for.

To be honest, the whole route validation scheme in ipv6 was
jackhammered into place.  It was basically two years of Alexey
repairing the largely broken scheme that Pedro had put into place.

This is ~1997 legacy stuff.

It deserves a complete rewrite, but we are too busy with ipv4 at the
moment.  And frankly if nobody other than myself was concerned enough
to delete the ipv4 routing cache (code people actually use) the
likelyhood of anyone embarking on a task of similar size for ipv6 is
basically zero.
