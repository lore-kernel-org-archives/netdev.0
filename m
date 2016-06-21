From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Tue, 21 Jun 2016 10:23:25 -0700
Message-ID: <CALx6S36kbGZBhxR-m-5jaxzzg53wrHAoi8XknnByZawApFKT8g@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
	<20160617.200947.2078656051211641868.davem@davemloft.net>
	<CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
	<4d1666f1-e52f-c7f6-9b9c-fec38b9ff028@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37495 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbcFURX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 13:23:27 -0400
Received: by mail-it0-f42.google.com with SMTP id f6so19549199ith.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 10:23:27 -0700 (PDT)
In-Reply-To: <4d1666f1-e52f-c7f6-9b9c-fec38b9ff028@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 10:11 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 17.06.2016 20:52, Tom Herbert wrote:
>>
>>> > Rather, I think people are going to start adding rules to block TOU
>>> > tunnels entirely because they cannot inspect nor conditionally
>>> > filter/rewrite the contents.  This is even more likely if Joe Random
>>> > and so easily can do their own userland TCP stack over TOU.
>>> >
>> Unfortunately, encryption is the only proven solution to protocol
>> ossification. If the network doesn't see it, it can't ossify it.
>
> DTLS carries still a lot of information, both in its handshake, as well
> as in the actual framing. The protocol is basically only TLS on top of
> datagrams and as such implements connection establishment and tear down
> of connections, which middle boxes can certainly track. It will just be
> a matter of time until middle boxes and security appliances will be able
> to track those connections, maybe not being able to inspect the content
> but at least see the certificates in clear-text and as such also have
> the common names and other addressing information at hand. The meta-data
> might certainly be track able.
>
> Because of reply protection you actually can infer the number of bytes
> transferred and someone can end up building congestion control on a
> middle box based on that, infer retransmissions etc.
>
Right, it's probably impossible to completely eliminate track-ability.
But hopefully we can keep the plain text information to the absolute
minimum needed to send the packet over the network and decrypt it at
the receiver.

One interesting characteristic of disassociated location is that we
could purposely try to manipulate ECMP so that every packet for a flow
take different paths so no single device (assuming multi-path) can
reconstruct the whole communication (kind of like spread spectrum for
the Internet). I imagine there are some might be some environments
where paranoids might want to do this.

Tom

> Bye,
> Hannes
>
