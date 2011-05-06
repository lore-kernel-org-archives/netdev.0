From: David Miller <davem@davemloft.net>
Subject: Re: ip_queue_xmit() used illegally
Date: Fri, 06 May 2011 13:21:29 -0700 (PDT)
Message-ID: <20110506.132129.59693228.davem@davemloft.net>
References: <20110506.122656.189696988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, yjwei@cn.fujitsu.com,
	jchapman@katalix.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36234
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755392Ab1EFUWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 16:22:02 -0400
In-Reply-To: <20110506.122656.189696988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 06 May 2011 12:26:56 -0700 (PDT)

> SCTP stores it's binding information using transports and assosciations
> and does not fill in the ->inet_{daddr,saddr} values.
> 
> It tries to work around this route issue by checking dst->obsolete
> directly in sctp_packet_transmit(), which just makes the race smaller
> and does not eliminate it.  ip_queue_xmit() can still end up with
> __sk_dst_check() returning NULL and then we end up emitting a
> potentially bogus packet.

I take this back, we added this hack where things like SCTP can
pre-route the packet by hooking up the route to the SKB before
calling ->queue_xmit.

And L2TP does something similar.

So false alarm, nothing to see here :-)

I still want to clean this up so that this kind of stuff can be
handled generically inside of ->queue_xmit() by passing in the correct
addressing information.
