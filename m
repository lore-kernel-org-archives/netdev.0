From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: minimum ICMPv6 message size vs. RPL's DIS
Date: Fri, 26 Jul 2013 01:31:34 +0200
Message-ID: <20130725233134.GA24247@order.stressinduktion.org>
References: <20130724232852.GA29572@ws> <20130725061731.GA12365@order.stressinduktion.org> <20130725103048.GB29572@ws> <20130725135820.GB11592@order.stressinduktion.org> <20130725143223.GC29572@ws> <20130725184044.GC24007@order.stressinduktion.org> <20130725214749.GD29572@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:40179 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab3GYXbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 19:31:35 -0400
Content-Disposition: inline
In-Reply-To: <20130725214749.GD29572@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 06:47:49PM -0300, Werner Almesberger wrote:
> Hannes Frederic Sowa wrote:
> > I don't know how they could do this if they want to let other RFCs extend
> > icmp types.
> 
> Oh, ICMPs can have padding. That's used to enforce "nice" alignment.
> Even RFC 6550 (RPL) has that. For example, you could simply pad the
> troublesome DIS, message which is
> 
> Offset	Value	Description
> ------	-----	------------------------------------------------
> 0	0x9b	ICMPv6 Type = RPL (155, section 6)
> 1	0x00	ICMPv6 Code = DODAG Information Solicitation (0)
> 2	0x??	Checksum
> 3	0x??	(continued)
> 
> 4	0x00	Flags = 0 (section 6.2.1)
> 5	0x00	Reserved
> 
> to eight bytes (i.e., four bytes of body) by adding
> 
> 6	0x01	Option Type = PadN (section 6.7.3)
> 7	0x00	Option Length = 0
> 
> But if nothing obliges the sender to do so, there's no excuse for
> Linux to expect such padding.

Yes, of course, that's possible but not specified at all in the general
ICMPv6 RFC.  If packets are too short for some medium, I guess, one
would stretch it with extension header paddings before the icmpv6 header.

> > Yes, that could be an issue. I would be willing to accept this fallout. :)
> 
> I'm kinda curious what sort of policy we have on that. The worst
> case would be that there's a bunch of 64 bit Linux machines out
> there, doing critical infrastructure things in the Internet (not an
> unlikely role, given the API in question), and their user space has
> some vulnerability if the kernel lets a "short" ICMPv6 packet
> through.

You forgot one critical aspect: Important infrastructure is *never*
going to be updated and definitely never runs IPv6. ;)

I don't think there is a policy, just intuition.

> Of course, "The Almesberger-Sowa Internet Meltdown of 2013" does
> have a nice ring to it, in an apocalyptic kind of way ...

I would like to avoid such a scenario, but have seen enough patches that
I kind of cooled down a bit. ;)

In summary, I agree, we should get both changes at once into the tree or
none (of course I would still change the pointer to something reasonable
and describe the circumstances in a comment if we don't change the
current behaviour).

Greetings,

  Hannes
