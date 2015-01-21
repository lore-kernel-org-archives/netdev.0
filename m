From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Wed, 21 Jan 2015 11:45:52 -0800
Message-ID: <CA+mtBx-v5dvX-OPGeWJb6uwQGhJ5T6iewD83xJGqXb+Ggf+LQw@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
	<CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com>
	<CALnjE+rSXpPftiG4Vw3azkN2s2-Ey6ZcZr9Bv422pOdwrvU=tw@mail.gmail.com>
	<CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com>
	<CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34598 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbbAUTpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 14:45:53 -0500
Received: by mail-ie0-f177.google.com with SMTP id at20so17681488iec.8
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 11:45:52 -0800 (PST)
In-Reply-To: <CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I used bare metal intel servers. All VXLAN tests were done using linux
> kernel device without any VMs. All STT tests are done using OVS bridge
> and STT port.
>
So right off the bat you're running the baseline differently than the
target. Anyway, I cannot replicate your numbers for VXLAN, I see much
better performance and this with pretty old servers and dumb NICs. I
suspect you might not have GSO/GRO properly enabled, but instead of
trying to debug your setup, I'd rather restate my request that you
provide a network interface to STT so we can do our own fair
comparison.

>> Another thing to consider in your analysis is the performance with
>> flows using small packets. STT should demonstrate better performance
>> with bulk flows since LSO and LRO are better performing relative to
>> GSO and GRO. But for flows with small packets, I don't see how there
>> could be any performance advantage. We already have ways to leverage
>> simple UDP checksum offload with UDP encapsulations, seems like STT
>> might just represent unnecessary header overhead in those cases.
>>
> All tunneling protocol has performance issue with small packet, I do
> not see how is it related to STT patch. STT also make use of checksum
> offload, so there should not be much overhead.
>

Given the pervasiveness of these patches and the fact that this is
"modifying" the definition of TCP protocol we see on the wire, I would
like to see more effort into analyzing performance and effects of this
encapsulation. I assume that STT is intended to be used for small
packets so it seems entirely reasonable to ask what exactly the
performance effects are for that case. It's really not that hard to
run some performance numbers with comparisons (TCP_RR, TCP_STREAM,
TCP_CRR, with IPv6, etc.) and report them in the patch set
description. You can look at FOU, GUE, vxlan rco, and the checksum
patches I did for some examples.

>>> VXLAN:
>>> CPU
>>>   Client: 1.6
>>>   Server: 14.2
>>> Throughput: 5.6 Gbit/s
>>>
>>> VXLAN with rcsum:
>>> CPU
>>>   Client: 0.89
>>>   Server: 12.4
>>> Throughput: 5.8 Gbit/s
>>>
>>> STT:
>>> CPU
>>>   Client: 1.28
>>>   Server: 4.0
>>> Throughput: 9.5 Gbit/s
>>>
>> 9.5Gbps? Rounding error or is this 40Gbps or larger than 1500 byte MTU?
>>
> Nope, its same as VXLAN setup, 10Gbps NIC with 1500MTU.
>
That would exceed that theoretical maximum for TCP over 10Gbps
Ethernet. How are you measuring throughput? How many bytes of protocol
headers are in STT case?

Thanks,
Tom

> Thanks.
