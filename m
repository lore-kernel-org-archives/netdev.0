From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 17 Jun 2016 20:52:55 -0700
Message-ID: <CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
	<20160617.200947.2078656051211641868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35543 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbcFRDw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 23:52:56 -0400
Received: by mail-it0-f67.google.com with SMTP id r66so503641itg.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:52:56 -0700 (PDT)
In-Reply-To: <20160617.200947.2078656051211641868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We also now have to debug against every single userland TCP
> implementation someone can come up with, the barrier to entry is
> insanely low with TOU.  Maybe this sounds great to you, but to me
> it is quite terrifying
>
No, it doesn't sound great, but the major problem we have is that
Android and to some extent iOS & Windows take a long time to update
the kernel, and it can take an _extremely_ long time if we need them
to actively enable features that are needed by applications. For
instance, TFO was put in the Linux several years ago, but it still
hasn't been enabled in Android and only fairly recently enabled in
iOS. If we (e.g. Facebook) implement a userspace stack in clients and
control the stack in our servers we can roll out a feature like that
in a couple of months. I don't see anyway to fix other than trying to
take control of our own destiny.  It seems like it's either this or
use something like QUIC which bypasses the kernel completely and
discards TCP-- we have far too much invested to commit to that
alternative at this point.

> This sounds really great on paper, however I find it hard to believe
> that makers of middleware boxes are just going to throw their hands in
> the air and say "oh well, we lose."
>
Happy Eyeballs is implied. There's pretty good data that the majority
(>90%) of the Internet will pass UDP without issue, QUIC is already
seeing good deployment and there are several UDP based protocols
productively deployed. There is also an effort in IETF, PLUS,  to
define a substrate layer that makes UDP based transport protocol
palatable to middleboxes with some sort of signaling.

> Rather, I think people are going to start adding rules to block TOU
> tunnels entirely because they cannot inspect nor conditionally
> filter/rewrite the contents.  This is even more likely if Joe Random
> and so easily can do their own userland TCP stack over TOU.
>
Unfortunately, encryption is the only proven solution to protocol
ossification. If the network doesn't see it, it can't ossify it.

> BTW, I have a question about the pseudo header checksum.  If the outer
> IP addresses can change, due to NAT or whatever, and therefore the
> session key is used for connection demuxing instead of the addresses,
> why don't we also have to use the session key instead of the IP
> addresses for the pseudo header used in checksum calculations?

Yes, the inner checksum will need to be handled differently in case of
NAT. Need to update draft to take that into account.

Thanks,
Tom
