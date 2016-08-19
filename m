From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Feature Request] IP_BIND_ADDRESS_NO_PORT with port
Date: Fri, 19 Aug 2016 15:33:53 -0700
Message-ID: <1471646033.29842.118.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAOWQn3S-wRip9ULjYvkdY-6Nb4+sT2bHXBMsN_B-0dXj-ZgkwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cristian Morales Vega <christian.morales.vega@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35244 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754305AbcHSWd4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 18:33:56 -0400
Received: by mail-pf0-f193.google.com with SMTP id h186so2043762pfg.2
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 15:33:56 -0700 (PDT)
In-Reply-To: <CAOWQn3S-wRip9ULjYvkdY-6Nb4+sT2bHXBMsN_B-0dXj-ZgkwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-08-19 at 23:41 +0300, Cristian Morales Vega wrote:
> I would like a socket option that let's me share a source port as long
> as the 4-tuples are unique in a UDP socket *and* specify which source
> port that is.
> It would be similar to IP_BIND_ADDRESS_NO_PORT. It would do exactly
> the same when you bind to port 0, but when you bind to a different
> port it would say "don't do anything with this port yet, but when I
> connect() please use the port as source port instead of a random
> ephemeral port".
> 
> The reason is the following. I would like to have a server receiving
> and sending UDP datagrams from multiple clients using a single port. I
> would like to use multiple sockets for sending, so I can use different
> SO_MAX_PACING_RATEs for each one. One socket per client/session.
> So there is a single "main socket" bind to the relevant port
> (equivalent to the one that accept()s in TCP), and when it receives a
> new session request it creates a new socket specific for that season
> (as accept() does). When creating that new socket I first need to
> bind() it to select the port, and then connect() it to make it receive
> only datagrams from the relevant session.
> The problem is that between the bind() and the connect() there is a
> small time in which the new socket can receive data that should go to
> the "main socket". It's not an unsolvable problem but makes the server
> code more complicated than it needs to be.

Yes, this is something I had on my plate for a while. This is indeed
something we can solve easily.
