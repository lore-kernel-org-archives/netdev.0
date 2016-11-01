From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded
 ICMP errors from offending packet
Date: Tue, 1 Nov 2016 09:39:24 -0700
Message-ID: <CALx6S35gXFU47i5_LF7Hs1JKGvh40OyJ5Sn-TWacbwiFb0VZ9A@mail.gmail.com>
References: <CALx6S35qmAwFfK1TNAcJJs1jK7JgM8U4MCh3wC8hkuf2qae+sw@mail.gmail.com>
 <8760oa9egg.fsf@redhat.com> <CALx6S36r0gzZ7ndmivsygZD9vX+EEv2sVEP=rmhQVzGB46Rkdg@mail.gmail.com>
 <af3e302e-4fd0-e63c-4520-63a6e2341c22@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jakub Sitnicki <jkbs@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34044 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752611AbcKAQja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:39:30 -0400
Received: by mail-qk0-f193.google.com with SMTP id o68so9509337qkf.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 09:39:30 -0700 (PDT)
In-Reply-To: <af3e302e-4fd0-e63c-4520-63a6e2341c22@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016 at 9:25 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 31.10.2016 20:25, Tom Herbert wrote:
>> The normal hash for TCP or UDP using ECMP is over <protocol, srcIP,
>> dstIP, srcPort, dstPort>. For an ICMP packet ECMP would most likely be
>> done over <protocol, srcIP, dstIP>. There really is no way to ensure
>> that an ICMP packet will follow the same path as TCP or any other
>> protocol. Fortunately, this is really isn't so terrible. The Internet
>> has worked this way ever since routers started using ports as input to
>> ECMP and that hasn't caused any major meltdown.
>
> The normal hash for forwarding is without srcPort or dstPort, so the
> same as ICMP and especially also because of fragmentation problematic I
> don't think a lot of routers use L4 port information for ECMP either.
>
I don't think we can define a "normal hash". There is no requirement
that routers do ECMP a certain way, or that they do ECMP, or that for
that matter that they even consistently route packets for the same
flow. All of this is optimization, not something we can rely on
operationally. So in the general case, regardless of anything we do in
the stack, either ICMP packets will follow the same path as the flow
are they won't. If they don't things still need to to work. So I still
don't see what material benefit this patch gives us.

Tom

> Bye,
> Hannes
>
