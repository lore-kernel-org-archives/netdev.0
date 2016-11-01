From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded
 ICMP errors from offending packet
Date: Tue, 1 Nov 2016 17:54:12 +0100
Message-ID: <e497d91e-d5a1-e1c8-753c-9ab82ea95265@stressinduktion.org>
References: <CALx6S35qmAwFfK1TNAcJJs1jK7JgM8U4MCh3wC8hkuf2qae+sw@mail.gmail.com>
 <8760oa9egg.fsf@redhat.com>
 <CALx6S36r0gzZ7ndmivsygZD9vX+EEv2sVEP=rmhQVzGB46Rkdg@mail.gmail.com>
 <af3e302e-4fd0-e63c-4520-63a6e2341c22@stressinduktion.org>
 <CALx6S35gXFU47i5_LF7Hs1JKGvh40OyJ5Sn-TWacbwiFb0VZ9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jakub Sitnicki <jkbs@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:54955 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750758AbcKAQyQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:54:16 -0400
In-Reply-To: <CALx6S35gXFU47i5_LF7Hs1JKGvh40OyJ5Sn-TWacbwiFb0VZ9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 01.11.2016 17:39, Tom Herbert wrote:
> On Tue, Nov 1, 2016 at 9:25 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 31.10.2016 20:25, Tom Herbert wrote:
>>> The normal hash for TCP or UDP using ECMP is over <protocol, srcIP,
>>> dstIP, srcPort, dstPort>. For an ICMP packet ECMP would most likely be
>>> done over <protocol, srcIP, dstIP>. There really is no way to ensure
>>> that an ICMP packet will follow the same path as TCP or any other
>>> protocol. Fortunately, this is really isn't so terrible. The Internet
>>> has worked this way ever since routers started using ports as input to
>>> ECMP and that hasn't caused any major meltdown.
>>
>> The normal hash for forwarding is without srcPort or dstPort, so the
>> same as ICMP and especially also because of fragmentation problematic I
>> don't think a lot of routers use L4 port information for ECMP either.
>>
> I don't think we can define a "normal hash". There is no requirement
> that routers do ECMP a certain way, or that they do ECMP, or that for
> that matter that they even consistently route packets for the same
> flow. All of this is optimization, not something we can rely on
> operationally. So in the general case, regardless of anything we do in
> the stack, either ICMP packets will follow the same path as the flow
> are they won't. If they don't things still need to to work. So I still
> don't see what material benefit this patch gives us.

There certainly is no standard ECMP hash algorithm. ;)

Even Linux IPv6 ECMP behaved like that for a long time (very bad). It
just routed put packets on different links without consulting any hash.
That exactly was the reason why it was unusable and was upgraded some
while ago.

I do remember a lot of IPv6 PMTU blackholes in the past, so every patch
that improves connectivity here seems valuable to me, even if it does
not fix the problem completely in the end.

Bye,
Hannes
