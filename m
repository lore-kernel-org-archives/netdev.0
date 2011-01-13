From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netdev: tilepro: Use
 is_multicast_ether_addr helper
Date: Wed, 12 Jan 2011 23:42:50 -0800 (PST)
Message-ID: <20110112.234250.10542369.davem@davemloft.net>
References: <4D2DE98F.1090705@tilera.com>
	<20110112.184501.00455226.davem@davemloft.net>
	<20110113065855.GU29757@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47688
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752220Ab1AMHmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 02:42:17 -0500
In-Reply-To: <20110113065855.GU29757@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 13 Jan 2011 07:58:55 +0100

> On 2011-01-13 at 03:45:01 +0100, David Miller <davem@davemloft.net> wrote:
>> From: Chris Metcalf <cmetcalf@tilera.com>
>> Date: Wed, 12 Jan 2011 12:49:03 -0500
>> 
>> > On 1/12/2011 4:31 AM, Tobias Klauser wrote:
>> >> Use is_multicast_ether_addr from linux/etherdevice.h instead of a custom
>> >> macro. Also remove the broadcast address check, as it is considered a
>> >> multicast address too.
>> >>
>> >> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
>> >> ---
>> >>  drivers/net/tile/tilepro.c |   10 +---------
>> >>  1 files changed, 1 insertions(+), 9 deletions(-)
>> > 
>> > Thanks, I've taken this into the Tilera tree!
>> 
>> Don't, his transformation is buggy.
> 
> Why?
> 
> Doesn't the code want to make sure that only unicast addresses get
> filtered?
> 
>> You can't get rid of the broadcast check, it needs to be there.
>> Think about it.
> 
> If a unicast address is in buf, is_multicast_ether_addr returns false
> (and is_broadcast_addr would too) and thus it would get filtered.

Ok, this may be correct, but it makes the code hard to read.

I think the old code, whilst redundant, is easier to understand.

Why not add a function "is_unicast_ether_addr()" and use that
here instead?

That solves all of the issues I have with your change.
