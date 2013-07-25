From: Werner Almesberger <werner@almesberger.net>
Subject: Re: minimum ICMPv6 message size vs. RPL's DIS
Date: Thu, 25 Jul 2013 18:47:49 -0300
Message-ID: <20130725214749.GD29572@ws>
References: <20130724232852.GA29572@ws>
 <20130725061731.GA12365@order.stressinduktion.org>
 <20130725103048.GB29572@ws>
 <20130725135820.GB11592@order.stressinduktion.org>
 <20130725143223.GC29572@ws>
 <20130725184044.GC24007@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.openmoko.org ([144.76.72.4]:47084 "EHLO
	hydra.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab3GYVtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 17:49:19 -0400
Content-Disposition: inline
In-Reply-To: <20130725184044.GC24007@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> I don't know how they could do this if they want to let other RFCs extend
> icmp types.

Oh, ICMPs can have padding. That's used to enforce "nice" alignment.
Even RFC 6550 (RPL) has that. For example, you could simply pad the
troublesome DIS, message which is

Offset	Value	Description
------	-----	------------------------------------------------
0	0x9b	ICMPv6 Type = RPL (155, section 6)
1	0x00	ICMPv6 Code = DODAG Information Solicitation (0)
2	0x??	Checksum
3	0x??	(continued)

4	0x00	Flags = 0 (section 6.2.1)
5	0x00	Reserved

to eight bytes (i.e., four bytes of body) by adding

6	0x01	Option Type = PadN (section 6.7.3)
7	0x00	Option Length = 0

But if nothing obliges the sender to do so, there's no excuse for
Linux to expect such padding.

> Yes, that could be an issue. I would be willing to accept this fallout. :)

I'm kinda curious what sort of policy we have on that. The worst
case would be that there's a bunch of 64 bit Linux machines out
there, doing critical infrastructure things in the Internet (not an
unlikely role, given the API in question), and their user space has
some vulnerability if the kernel lets a "short" ICMPv6 packet
through.

Of course, "The Almesberger-Sowa Internet Meltdown of 2013" does
have a nice ring to it, in an apocalyptic kind of way ...

- Werner
