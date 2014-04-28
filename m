From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH 2/2] ipv6: Set flow label to skb_hash on transmit
Date: Mon, 28 Apr 2014 22:49:02 +0200
Message-ID: <535EBEBE.9090703@enst-bretagne.fr>
References: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>	<535E99F3.3050404@enst-bretagne.fr>	<CA+mtBx-umd3vmNggurFiugQXr_gb+14HvHo=jdaPnpC4cL=tdA@mail.gmail.com>	<535EADFD.4050508@enst-bretagne.fr> <CA+mtBx8uiOw8GnpOgQamPLg-MPLYHr4=rALpW9OKGW1hR+KK_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:51949 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbaD1UtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 16:49:07 -0400
In-Reply-To: <CA+mtBx8uiOw8GnpOgQamPLg-MPLYHr4=rALpW9OKGW1hR+KK_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> If someone is implementing a strong policy for
> flow labels (like dropping based on it), it would be incorrect.
> RFC6437 is clear on this:
> 

And correct for RFC 3697:

>    A source node MUST ensure that it does not unintentionally reuse Flow
>    Label values it is currently using or has recently used when creating
>    new flows.

The situation is very uncomfortable, but the choice is to break old
implementations based on a rule valid between (at least) 2004 and 2011,
or to follow the newer RFC. If we not set it by default, the
distributions still have the choice to enable it.


>> As second point, the name of auto_flowlabel is in my opinion not a
>> perfect choice if you set a label it only on tunnels. This is exactly
>> the same name that a BSD sysctl, setting a random label on all sockets
>> (TCP, UDP...). The flow label world is already hard enough to
>> understand, thanks to various implementations.
>>
> This is not just for tunnels, but would apply to transports and
> potentially obviates the need for a lot of UDP encapsulation (like
> ESP/UDP). So it would appear that this is pretty much the same thing
> as what the BSD implementation does and same sysctl name (a happy
> coincidence). Looks like the default in BSD is on btw.
> 

Oups sorry, I missed the line in the patch for the transports. If you
follow the BSD implementation, what about the IPV6_AUTOFLOWLABEL socket
option, to disable/enable it only on some sockets? (the enable is
actually already available thanks to the manager).
