From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Wed, 09 Mar 2011 13:08:17 -0800 (PST)
Message-ID: <20110309.130817.115943793.davem@davemloft.net>
References: <alpine.LFD.2.00.1103081030090.1529@ja.ssi.bg>
	<20110308.103801.193702247.davem@davemloft.net>
	<alpine.LFD.2.00.1103090157400.2880@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42296
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752526Ab1CIVHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 16:07:39 -0500
In-Reply-To: <alpine.LFD.2.00.1103090157400.2880@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 9 Mar 2011 02:49:49 +0200 (EET)

> 	But we still need to propagate the address events
> to nexthops on all devices. Even if it is slow, I see it in
> this way (not tested):

Ok, I think it is even more involved than what you propose.

We have to potentially re-run inet_select_addr() on all nexthops, even
those pointing to devices other than the one being modified, because
when an interface loses it's last IP address we have to look for a
source address to use on other active interfaces.

Probably it makes sense to recompute this at use time instead of
walking all of this stuff at every event.

So device address operations increment a generation ID and
FIB_RES_PREFSRC() checks that ID against one stored in the nexthop.
