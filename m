From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: skip loopback checksums in ip_rcv()
Date: Mon, 19 Oct 2009 17:24:55 -0700 (PDT)
Message-ID: <20091019.172455.139931137.davem@davemloft.net>
References: <200910192134.02125.schmto@hrz.tu-chemnitz.de>
	<4ADCCF1A.7070301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45304
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751077AbZJTAYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 20:24:33 -0400
In-Reply-To: <4ADCCF1A.7070301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Oct 2009 22:42:02 +0200

> One bit could be corrupted in iph, and ntohl(iph->daddr) becomes 0x7fxxyyzz,
> we then accept a bogus frame. This is a RFC violation.
> 
> This also slows down non loopback devices, adding an extra test.
> 
> ip_fast_csum() is really fast (about 16 instructions).

Also loopback doesn't mean anything.  That packet could
be mirrored and sent externally via packet scheduler
rules and actions.

And for this specific case, the savings are absolutely zero.

We've brought the whole damn IP header into the CPU cache and
that is the real cost.  The calculation is something like 12
instructions, maybe 6 cycles on a modern cpu, which is nothing.
