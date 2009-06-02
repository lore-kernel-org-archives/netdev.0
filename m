From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 01 Jun 2009 20:54:06 -0500
Message-ID: <1243907646.15854.16.camel@merlyn>
References: <4A23F027.3060907@dev.6wind.com>
	 <20090601161917.GA29745@Chamillionaire.breakpoint.cc>
	 <4A240681.2010300@6wind.com> <4A242161.3010609@cosmosbay.com>
	 <4A242418.1090804@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, nicolas.dichtel@6wind.com,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:50972 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708AbZFBByI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 21:54:08 -0400
Received: by gxk10 with SMTP id 10so13701483gxk.13
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2009 18:54:09 -0700 (PDT)
In-Reply-To: <4A242418.1090804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-01 at 14:55 -0400, Brian Haley wrote: 
> 'ping6 -t 0 host' does work however.  The problem I see is that if you ping a system,
> if it's a host it will respond, if it's a router it won't - the RFCs don't
> explicitly state the host should drop the packet.  

There are two cases--an echo request to an address assigned to a
router's interface, and to an address _beyond_ the router on another
link.

Any given interface on a router can have forwarding dynamically enabled
or disabled.  I don't remember prescribed echo request or hop limit
behavior changing depending on the forwarding enable, so it seems that
if you ping an address assigned to a router's interface, the router is
expected to follow the (apparently unwritten) host rules.  

Echo requests forwarded by a router should obviously have the hop limit
decremented and checked.

> I don't know if that difference
> in behavior is desired.  Do we know how any other OSes behave?

FWIW, the random BSD flavors I have on hand all check hop limit when
forwarding, but not when processing local ingress traffic.

Also FWIW, as I remember, the TAHI tests only check hop limit behavior
on forwarded traffic.

Nicolas, what's driving your patch?  Are you trying to align slow path
behavior with one of the 6WIND fast path implementations?

  --  John

