From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Wed, 07 Dec 2016 09:52:54 -0800
Message-ID: <1481133174.4930.42.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34743 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753112AbcLGRx4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:53:56 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so24088007pgc.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 09:53:56 -0800 (PST)
In-Reply-To: <1481132267.1541189.811630457.167E9C56@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 18:37 +0100, Hannes Frederic Sowa wrote:

> I had the same idea while discussing that with Paolo, merely using an
> *atomic_t = kmalloc(sizeof(atomic_t)) out of band of the socket.
> 
> My fear was that those could be aggregated by the slab cache into one
> cache line, causing even more heating on cachelines.

For hot stuff, better use kmalloc(max_t(size_t, 
                                        L1_CACHE_BYTES,
                                        sizeof(...)) 
to avoid false sharing, unless this is per cpu data of course.
