From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Cannot set IPv6 address
Date: Thu, 17 Nov 2016 11:55:33 +0200
Message-ID: <CALzJLG-3K=WJ5OXN1Ho41_7ce9ktnxtaiG+FDCtdDGe7=meGAg@mail.gmail.com>
References: <CALzJLG9B52CbMEiWgroaihq4Ar2Jc9H3BZdA_xjF37CZESbZ8Q@mail.gmail.com>
 <1479310198.8455.199.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: david.lebrun@uclouvain.be,
        Linux Netdev List <netdev@vger.kernel.org>,
        Doron Tsur <doront@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36570 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751359AbcKQJzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 04:55:55 -0500
Received: by mail-wm0-f67.google.com with SMTP id m203so19475923wma.3
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 01:55:54 -0800 (PST)
In-Reply-To: <1479310198.8455.199.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 5:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-11-16 at 17:22 +0200, Saeed Mahameed wrote:
>> Hi David,
>>
>> The following commit introduced a new issue when setting IPv6 address
>> via the following command:
>>
>> /sbin/ip -6 addr add 2001:0db8:0:f112::1/64 dev enp2s2
>> RTNETLINK answers: Operation not supported
>>
>> Offending commit:
>>
>> commit 6c8702c60b88651072460f3f4026c7dfe2521d12
>> Author: David Lebrun <david.lebrun@uclouvain.be>
>> Date:   Tue Nov 8 14:57:41 2016 +0100
>>
>>     ipv6: sr: add support for SRH encapsulation and injection with lwtunnels
>>
>>     This patch creates a new type of interfaceless lightweight tunnel (SEG6),
>>     enabling the encapsulation and injection of SRH within locally emitted
>>     packets and forwarded packets.
>>
>>     >From a configuration viewpoint, a seg6 tunnel would be configured
>> as follows:
>>
>>       ip -6 ro ad fc00::1/128 encap seg6 mode encap segs
>> fc42::1,fc42::2,fc42::3 dev eth0
>>
>>     Any packet whose destination address is fc00::1 would thus be encapsulated
>>     within an outer IPv6 header containing the SRH with three
>> segments, and would
>>     actually be routed to the first segment of the list. If `mode inline' was
>>     specified instead of `mode encap', then the SRH would be directly inserted
>>     after the IPv6 header without outer encapsulation.
>>
>>     The inline mode is only available if CONFIG_IPV6_SEG6_INLINE is
>> enabled. This
>>     feature was made configurable because direct header insertion may break
>>     several mechanisms such as PMTUD or IPSec AH.
>>
>>     Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>>
>> Can you check ? Are we missing something here ?
>
> Sure, patch is under review. Please look at netdev archives and/or
> ozlabs
>
> https://patchwork.ozlabs.org/patch/695060/
>
>

Thank you Eric.
