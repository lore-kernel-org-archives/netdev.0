From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Wed, 07 Dec 2016 09:55:12 -0800
Message-ID: <1481133312.4930.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0237532@AcuExch.aculab.com>
         <1481131924.4930.40.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481132267.1541189.811630457.167E9C56@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
        Paolo Abeni <pabeni@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36603 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932215AbcLGR4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:56:14 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so24131444pgx.3
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 09:56:14 -0800 (PST)
In-Reply-To: <1481132267.1541189.811630457.167E9C56@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 18:37 +0100, Hannes Frederic Sowa wrote:

> I had the same idea while discussing that with Paolo, merely using an
> *atomic_t = kmalloc(sizeof(atomic_t)) out of band of the socket.
> 
> My fear was that those could be aggregated by the slab cache into one
> cache line, causing even more heating on cachelines.

My exact idea was to let up to 4095 (or PAGE_SIZE - 1) increments being
done on the counter before switching to dynamically allocated memory.

( Some packets might be dropped by TCP sockets, not necessarily a sign
of an attack. just some spurious retransmits )
