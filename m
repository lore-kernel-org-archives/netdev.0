From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] net: make net.core.{r,w}mem_{default,max} namespaced
Date: Tue, 01 Aug 2017 02:17:20 -0400
Message-ID: <87wp6nerrj.fsf@stressinduktion.org>
References: <20170726170333.24580-1-mcroce@redhat.com>
        <1501495652.1876.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matteo Croce <mcroce@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49991 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750763AbdHAGRY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 02:17:24 -0400
In-Reply-To: <1501495652.1876.17.camel@edumazet-glaptop3.roam.corp.google.com>
        (Eric Dumazet's message of "Mon, 31 Jul 2017 03:07:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Wed, 2017-07-26 at 19:03 +0200, Matteo Croce wrote:
>> The following sysctl are global and can't be read or set from a netns:
>> 
>> net.core.rmem_default
>> net.core.rmem_max
>> net.core.wmem_default
>> net.core.wmem_max
>> 
>> Make the following sysctl parameters available from within a network
>> namespace, allowing to set unique values per network namespace.
>> 
>> My concern is about the initial value of this sysctl in the newly
>> creates netns: I'm not sure if is better to copy them from the init
>> namespace or set them to the default values.
>> 
>> Setting them to the default value has the advantage that a new namespace
>> behaves like a freshly booted system, while copying them from the init
>> netns has the advantage of keeping the current behaviour as the values
>> from the init netns are used.
>> 
>> Signed-off-by: Matteo Croce <mcroce@redhat.com>
>> ---
>
> It looks that these sysctls were giving some kind of isolation.
>
> If we make them per namespace, a malicious usage could eat all memory
> and hurt other namespaces.

We do account rmem as well as wmem allocated memory to the apropriate
mem_cgs. In theory this should be okay.

Bye,
Hannes
