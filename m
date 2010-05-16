From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Consistent skb timestamping
Date: Sat, 15 May 2010 23:56:35 -0700 (PDT)
Message-ID: <20100515.235635.63009445.davem@davemloft.net>
References: <1273147309.2357.59.camel@edumazet-laptop>
	<AANLkTikLgHvtpCtBTKmJZBwixmZDHjRjGb1c59oAemli@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45165
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751337Ab0EPG41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:56:27 -0400
In-Reply-To: <AANLkTikLgHvtpCtBTKmJZBwixmZDHjRjGb1c59oAemli@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 6 May 2010 08:12:57 -0700

> I'm contemplating changing SO_TIMESTAMP to not enable global
> timestamps, but only take the timestamp for a packet once the socket
> is identified and the timestamp flag is set (this is the technique
> done in FreeBSD and Solaris, so I believe the external semantics
> would still be valid).

This is not tenable.

Users have made it clear in the past that when they ask for a timestamp
they really want the timestamp as close to the device receive handling
path as possible.

Users basically really want timestamps in two places:

1) As near the device RX handling as possible

2) The point at which recvmsg() got the data

The former is obtainable from SO_TIMESTAMP and the latter from
gettimeofday().

So putting it way down to the point where we choose the socket isn't
going to work at all.

FreeBSD and Solaris combined have a tiny sliver of the number of users
we have to cater to, so they can have all kinds of latitude with which
to break things like that.  So saying they do something is like saying
"the moon was out tonight", it has no relevance on whether we are able
to do it too :-)

The real fix is to make the devices less stupid and give us timestamps
directly, and thanks to things like PTP support in hardware that's
actually more and more of a reality these days.
