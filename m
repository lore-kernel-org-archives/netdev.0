From: Cristian Morales Vega <christian.morales.vega@gmail.com>
Subject: [Feature Request] IP_BIND_ADDRESS_NO_PORT with port
Date: Fri, 19 Aug 2016 23:41:04 +0300
Message-ID: <CAOWQn3S-wRip9ULjYvkdY-6Nb4+sT2bHXBMsN_B-0dXj-ZgkwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36519 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754893AbcHSUlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 16:41:06 -0400
Received: by mail-io0-f194.google.com with SMTP id y34so5396021ioi.3
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 13:41:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like a socket option that let's me share a source port as long
as the 4-tuples are unique in a UDP socket *and* specify which source
port that is.
It would be similar to IP_BIND_ADDRESS_NO_PORT. It would do exactly
the same when you bind to port 0, but when you bind to a different
port it would say "don't do anything with this port yet, but when I
connect() please use the port as source port instead of a random
ephemeral port".

The reason is the following. I would like to have a server receiving
and sending UDP datagrams from multiple clients using a single port. I
would like to use multiple sockets for sending, so I can use different
SO_MAX_PACING_RATEs for each one. One socket per client/session.
So there is a single "main socket" bind to the relevant port
(equivalent to the one that accept()s in TCP), and when it receives a
new session request it creates a new socket specific for that season
(as accept() does). When creating that new socket I first need to
bind() it to select the port, and then connect() it to make it receive
only datagrams from the relevant session.
The problem is that between the bind() and the connect() there is a
small time in which the new socket can receive data that should go to
the "main socket". It's not an unsolvable problem but makes the server
code more complicated than it needs to be.
