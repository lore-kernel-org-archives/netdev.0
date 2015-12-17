From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 2/2] udp: restrict offloads to one namespace
Date: Thu, 17 Dec 2015 18:40:12 +0100
Message-ID: <5672F37C.9040602@stressinduktion.org>
References: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
 <1450209714-26037-2-git-send-email-hannes@stressinduktion.org>
 <20151216.190417.1337922066819496682.davem@davemloft.net>
 <56727731.2010605@stressinduktion.org>
 <CALx6S36B5LFgJqJB7Q98Z2KF74Ee3UDiqva6fm+8HEo_KFfTMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39963 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751348AbbLQRkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 12:40:14 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 0200B20731
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 12:40:13 -0500 (EST)
In-Reply-To: <CALx6S36B5LFgJqJB7Q98Z2KF74Ee3UDiqva6fm+8HEo_KFfTMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.12.2015 18:32, Tom Herbert wrote:
> On Thu, Dec 17, 2015 at 12:49 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> With user namespaces a normal user can start a new network namespace
>> with all privileges and thus add new offloads, letting the other stack
>> interpret this garbage. Because the user namespace can also add
>> arbitrary ip addresses to its interface, solely matching those is not
>> enough.
>>
>> Tom any further comments?
>>
> I still don't think this addresses the core problem. If we're just
> worried about offloads being added in a user namespace that conflict
> with the those in the root space, it might be just as easy to disallow
> setting offloads except in default namespace.

I am fine with that solution, too.

> [...]
>
> To address this in the host stack the solution is pretty
> straightforward, we need to decide that the packet is going to be
> received before applying any offloads. Essentially we want to do an
> early_demux _really_ early. If we demux and get UDP socket for
> instance, then the protocol specific GRO function can be retrieved
> from the socket. So this will work with single listener port like
> encaps do today,  and also if encapsulation is being used over a
> connected socket. This also works if we want to support a user defined
> GRO function like I mentioned we might want to do for QUIC etc.

An approximation can be done, but I don't think it is feasible to
implement this kind of checks across namespace borders, ip rules and
netfilter rulesets, which could all change the outcome of the process.

Bye,
Hannes
