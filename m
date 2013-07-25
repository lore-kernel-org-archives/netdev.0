From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: minimum ICMPv6 message size vs. RPL's DIS
Date: Thu, 25 Jul 2013 20:40:44 +0200
Message-ID: <20130725184044.GC24007@order.stressinduktion.org>
References: <20130724232852.GA29572@ws> <20130725061731.GA12365@order.stressinduktion.org> <20130725103048.GB29572@ws> <20130725135820.GB11592@order.stressinduktion.org> <20130725143223.GC29572@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:39746 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756958Ab3GYSkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 14:40:45 -0400
Content-Disposition: inline
In-Reply-To: <20130725143223.GC29572@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 11:32:23AM -0300, Werner Almesberger wrote:
> Hannes Frederic Sowa wrote:
> > I would say no problem. But as I just realized that it could be a bit
> > problematic because the new defines have actually pretty common names,
> > let's cc David Miller. Perhaps he has an advice?
> 
> Yeah, I'll let the issue sit here for a while so that more people
> can comment. The change has numerous implications, including
> 
> - there may actually be a minimum size requirement *somewhere*
>   and I just didn't find it, in which case Linux would be right,

I don't know how they could do this if they want to let other RFCs extend
icmp types. It definitely makes sense that an icmpv6 packet could not have any
payload (only for informational icmpv6 packets, error icmp msgs must have 32
bits of payload, see Apendix A - RFC4443).

> - name pollution visible to future user space,

I did a search on codesearch.debian.org and the change seems safe from
a first glimpse.

> - subtly changes kernel API semantics for ICMPv6 receivers, to
>   the detriment of those that rely on the kernel to filter
>   messages < 8 bytes and misbehave if exposed to them.

Yes, that could be an issue. I would be willing to accept this fallout. :)

> So this is definitely not the kind of change I want to rush.
> 
> Even the pointer fix changes the API in a way that could break
> applications that currently work (if only on 32 bit platforms,
> but it's not their fault that things would go wrong on 64 bit),
> so we can't apply that one before having a decision on the other
> issue as well.

Yes, you are right!

Thanks,

  Hannes
