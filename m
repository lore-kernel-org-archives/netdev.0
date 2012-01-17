From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: HSR: Standard breaks alignment. Solution?
Date: Tue, 17 Jan 2012 09:04:41 +0100
Message-ID: <1326787481.3342.2.camel@jlt3.sipsolutions.net>
References: <4F14AE66.7060301@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arvid Brodin <arvid.brodin@enea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:57744 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab2AQIEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 03:04:45 -0500
In-Reply-To: <4F14AE66.7060301@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-17 at 00:10 +0100, Arvid Brodin wrote:
> As I've written before here, I'm trying to add support for the HSR protocol
> ("High-availability Seamless Redundancy") to the linux kernel. The protocol is
> specified in IEC-62439-3, and involves adding a protocol tag after the ethhdr
> on outgoing frames, and stripping it again on reception, much like VLAN.
> 
> This HSR tag is 6 bytes long, which breaks 32-bit header alignment and causes
> an Oops and a kernel panic in icmp_echo on the receiving side of pings (here,
> exactly: http://lxr.linux.no/#linux+v2.6.37/net/ipv4/icmp.c#L838 )
> 
> If I add two bytes of padding to the HSR tag everything works beautifully. But
> of course that breaks any pretense of standard compliance.
> 
> Is there some way to fix this without having to memmove the whole frame payload
> 2 bytes on reception?

I don't think there's any other choice, but you can use
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS to see whether you actually need
to do it.

johannes
