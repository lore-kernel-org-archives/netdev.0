From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/2] ipv6: Set flow label to skb_hash on transmit
Date: Mon, 28 Apr 2014 14:13:12 -0700
Message-ID: <CA+mtBx-OzFHAhXaYimiS4vkB9K6MDjXYHtF5M6EdW3RV3FYQTA@mail.gmail.com>
References: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>
	<535E99F3.3050404@enst-bretagne.fr>
	<CA+mtBx-umd3vmNggurFiugQXr_gb+14HvHo=jdaPnpC4cL=tdA@mail.gmail.com>
	<535EADFD.4050508@enst-bretagne.fr>
	<CA+mtBx8uiOw8GnpOgQamPLg-MPLYHr4=rALpW9OKGW1hR+KK_w@mail.gmail.com>
	<535EBEBE.9090703@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:46815 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755621AbaD1VNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 17:13:12 -0400
Received: by mail-ig0-f173.google.com with SMTP id hl10so5318051igb.6
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 14:13:12 -0700 (PDT)
In-Reply-To: <535EBEBE.9090703@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 1:49 PM, Florent Fourcot
<florent.fourcot@enst-bretagne.fr> wrote:
>
>> If someone is implementing a strong policy for
>> flow labels (like dropping based on it), it would be incorrect.
>> RFC6437 is clear on this:
>>
>
> And correct for RFC 3697:
>
>>    A source node MUST ensure that it does not unintentionally reuse Flow
>>    Label values it is currently using or has recently used when creating
>>    new flows.
>
> The situation is very uncomfortable, but the choice is to break old
> implementations based on a rule valid between (at least) 2004 and 2011,
> or to follow the newer RFC. If we not set it by default, the
> distributions still have the choice to enable it.
>
Agreed, following robustness principle I will concede that the
conservative approach is to not enable auto_flowlabel by default. But
for RX purposes, the implementation needs to be consistent with 6437--
again we should not enforce that a received flow label corresponds to
a stateful connection (BSD would apparently break that). This might be
something that needs to be considered with flowlabel manager?

>
>>> As second point, the name of auto_flowlabel is in my opinion not a
>>> perfect choice if you set a label it only on tunnels. This is exactly
>>> the same name that a BSD sysctl, setting a random label on all sockets
>>> (TCP, UDP...). The flow label world is already hard enough to
>>> understand, thanks to various implementations.
>>>
>> This is not just for tunnels, but would apply to transports and
>> potentially obviates the need for a lot of UDP encapsulation (like
>> ESP/UDP). So it would appear that this is pretty much the same thing
>> as what the BSD implementation does and same sysctl name (a happy
>> coincidence). Looks like the default in BSD is on btw.
>>
>
> Oups sorry, I missed the line in the patch for the transports. If you
> follow the BSD implementation, what about the IPV6_AUTOFLOWLABEL socket
> option, to disable/enable it only on some sockets? (the enable is
> actually already available thanks to the manager).

I doubt a socket option would be very useful. The goal is to affect
aggregate behavior in the network which means we'd want it to be
generally used. As I mentioned, my primary use case would be to use
this with ESP (transport or tunnel mode) so we can avoid an extra UDP
encap with IPv6 for getting things like RPS and ECMP.

Thanks,
Tom
