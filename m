From: David Miller <davem@davemloft.net>
Subject: Re: NETIF_F_FRAGLIST and NETIF_F_SG difference
Date: Mon, 01 Mar 2010 19:01:23 -0800 (PST)
Message-ID: <20100301.190123.25445477.davem@davemloft.net>
References: <1267448321.2819.15.camel@localhost>
	<20100301.174024.214216263.davem@davemloft.net>
	<1267498318.2819.21.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mekaviraj@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753048Ab0CBDBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 22:01:07 -0500
In-Reply-To: <1267498318.2819.21.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 02 Mar 2010 02:51:58 +0000

> On Mon, 2010-03-01 at 17:40 -0800, David Miller wrote:
>> From: Ben Hutchings <bhutchings@solarflare.com>
>> Date: Mon, 01 Mar 2010 12:58:41 +0000
>> 
>> > (I don't know why there are two ways of adding extra data.  The latter
>> > does not seem to be used often.)
>> 
>> It's the most efficient way to handle IPv4/IPv6 fragmentation and
>> reassembly.
> 
> But fragmentation results in a series of packets to be transmitted
> separately (not gathered) and reassembly is only done at endpoints.  So
> when would we see a fragment list on the transmit path?

If the device indicates it can take the set of fragments as a bundle,
with only one IP header at the front, instead of individual fully
header'd IP frames.

This was the original intention of what this net device feature flag
was to be used for.

The device does all of the IP header creation for the individual
frames, bumping the fragment ID and flags, etc.  Just like it does
for TSO.

Some broadcom chips can do this, if I recall correctly.

But that never materialized.  Instead it now simply means that
the frag list based linkage is supported, and the packet is an
entire fully formed frame.

GSO/GRO makes use of the current interpretation so that the it's
bundles can be passed around efficiently from RX to TX.  Mostly the
feature bit is set by layered and virtualization devices.
