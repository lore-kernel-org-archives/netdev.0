From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 2/2] udp: restrict offloads to one namespace
Date: Thu, 17 Dec 2015 21:33:32 +0100
Message-ID: <56731C1C.60001@stressinduktion.org>
References: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
 <1450209714-26037-2-git-send-email-hannes@stressinduktion.org>
 <20151216.190417.1337922066819496682.davem@davemloft.net>
 <56727731.2010605@stressinduktion.org>
 <CALx6S36B5LFgJqJB7Q98Z2KF74Ee3UDiqva6fm+8HEo_KFfTMA@mail.gmail.com>
 <5672F37C.9040602@stressinduktion.org>
 <CALx6S363K9DXbPq0VCd8+AW-5v3oz+AXMnDF5-BBarh-WTsUGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:52237 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932139AbbLQUdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:33:35 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 4A07C209EF
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 15:33:35 -0500 (EST)
In-Reply-To: <CALx6S363K9DXbPq0VCd8+AW-5v3oz+AXMnDF5-BBarh-WTsUGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.12.2015 19:10, Tom Herbert wrote:
> On Thu, Dec 17, 2015 at 9:40 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 17.12.2015 18:32, Tom Herbert wrote:
>>> On Thu, Dec 17, 2015 at 12:49 AM, Hannes Frederic Sowa
>>> <hannes@stressinduktion.org> wrote:
>>>> With user namespaces a normal user can start a new network namespace
>>>> with all privileges and thus add new offloads, letting the other stack
>>>> interpret this garbage. Because the user namespace can also add
>>>> arbitrary ip addresses to its interface, solely matching those is not
>>>> enough.
>>>>
>>>> Tom any further comments?
>>>>
>>> I still don't think this addresses the core problem. If we're just
>>> worried about offloads being added in a user namespace that conflict
>>> with the those in the root space, it might be just as easy to disallow
>>> setting offloads except in default namespace.
>>
>> I am fine with that solution, too.
>>
>>> [...]
>>>
>>> To address this in the host stack the solution is pretty
>>> straightforward, we need to decide that the packet is going to be
>>> received before applying any offloads. Essentially we want to do an
>>> early_demux _really_ early. If we demux and get UDP socket for
>>> instance, then the protocol specific GRO function can be retrieved
>>> from the socket. So this will work with single listener port like
>>> encaps do today,  and also if encapsulation is being used over a
>>> connected socket. This also works if we want to support a user defined
>>> GRO function like I mentioned we might want to do for QUIC etc.
>>
>> An approximation can be done, but I don't think it is feasible to
>> implement this kind of checks across namespace borders, ip rules and
>> netfilter rulesets, which could all change the outcome of the process.
>>
> For receive offloads we don't need to worry about checking other namespaces.

That is true. Albeit for net-branch/stable I would still suggest either
this patch or restricting udp offloads just to the initial net namespace.

Bye,
Hannes
