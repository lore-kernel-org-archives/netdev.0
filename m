From: jamal <hadi@cyberus.ca>
Subject: Re: igmp snooping?
Date: Wed, 18 May 2005 21:10:59 -0400
Message-ID: <1116465059.6240.20.camel@localhost.localdomain>
References: <20050518221401.GA11148@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050518221401.GA11148@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-19-05 at 00:14 +0200, Lennert Buytenhek wrote:
> Hi,
> 
> Is someone working on igmp snooping (and/or active discovery) for
> bridging yet?  I currently have a need for this, so if noone is
> working on it yet, I'll probably give it a go myself.
> 

Not that i know of - someone else may.

> AFAICS, for the kernel part:
> - Add capability to add/modify/delete multicast (ethernet) addresses
>   in the forwarding database.  Each multicast fdb entry contains a port
>   bitmask of ports that are interested in this address.

You would probably also need to do a SIOCADDMULTI for those ports -
unless bridging puts all those ports in promisc mode. If it doesnt go
promisc, you _may_ also need to worry about boundary conditions when the
tiny physical devices hardware multicast entries start overflowing.

> - Lookup multicast addresses in the forwarding path, instead of flooding
>   every packet.
> - Policy decision on whether to drop or flood traffic for multicast
>   addresses that have no corresponding fdb entry.

Make this configurable. i.e flood on miss, drop on miss, pass to user
space(daemon if one exists) on a miss. 

> - Add capability for userland to 'steal' IGMP packets.  (I.e. to be able
>   to prevent them from being forwarded.)
> 

That would be the the last policy above. 
I think you will also need to have something that just listens to the
different IGMP variants (maybe a packet socket with a pcap filter).
The nice thing about pcap (in mmaped format) is it will tell you about
the ifindex of port it arrived on.

> And some userspace daemon that implements the necessary bits.
> 
> Ideas?
> 

Above. Also take note of:
http://www.ietf.org/internet-drafts/draft-ietf-magma-snoop-12.txt

Many years of experience there on snooping IGMP.
I think your most exciting challenge would be snooping IGMPv3 ;->

cheers,
jamal
