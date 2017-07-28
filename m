From: Christoph Paasch <christoph.paasch@gmail.com>
Subject: Re: TCP fast retransmit issues
Date: Thu, 27 Jul 2017 23:53:35 -0700
Message-ID: <CALMXkpYB8TOR+3Av3rX+GJhuvfDob8wkNyXysUQDOJgOM8OLxQ@mail.gmail.com>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk> <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk> <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170726134242.GB1737@1wt.eu> <1501079532.12695.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Willy Tarreau <w@1wt.eu>, Klavs Klavsen <kl@vsen.dk>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35824 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbdG1Gxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 02:53:37 -0400
Received: by mail-pf0-f174.google.com with SMTP id e75so14260656pfj.2
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 23:53:36 -0700 (PDT)
In-Reply-To: <1501079532.12695.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Jul 26, 2017 at 7:32 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-07-26 at 15:42 +0200, Willy Tarreau wrote:
>> On Wed, Jul 26, 2017 at 06:31:21AM -0700, Eric Dumazet wrote:
>> > On Wed, 2017-07-26 at 14:18 +0200, Klavs Klavsen wrote:
>> > > the 192.168.32.44 is a Centos 7 box.
>> >
>> > Could you grab a capture on this box, to see if the bogus packets are
>> > sent by it, or later mangled by a middle box ?
>>
>> Given the huge difference between the window and the ranges of the
>> values in the SACK field, I'm pretty sure there's a firewall doing
>> some sequence numbers randomization in the middle, not aware of SACK
>> and not converting these ones. I've had to disable such broken
>> features more than once in field after similar observations! Probably
>> that the Mac doesn't advertise SACK support and doesn't experience the
>> problem.
>
> We need to check RFC if such invalid SACK blocks should be ignored (DUP
> ACK would be processed and trigger fast retransmit anyway), or strongly
> validated (as I suspect we currently do), leading to a total freeze.

quite some time ago this issue with sequence number randomizing
middleboxes came already up
(http://marc.info/?l=netfilter-devel&m=137691623129822&w=2). From what
I remember, the RFC does not say that invalid SACK blocks should  be
strongly validated. So, trigger dup-ack retransmission seems fine.

I had some patches at the time that ignored invalid sack-blocks and
allowed fast-retransmit to happen thanks to the duplicate acks:
https://patchwork.ozlabs.org/patch/268297/
https://patchwork.ozlabs.org/patch/268298/


Cheers,
Christoph
