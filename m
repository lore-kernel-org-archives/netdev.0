From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 20:16:26 +0100
Message-ID: <1481051786.7129.22.camel@redhat.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481049061.7129.18.camel@redhat.com>
         <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51174 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751495AbcLFTQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 14:16:29 -0500
In-Reply-To: <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 10:58 -0800, Eric Dumazet wrote:
> On Tue, 2016-12-06 at 19:31 +0100, Paolo Abeni wrote:
> 
> > cacheline 2 boundary (128 bytes) is 8 bytes before sk_lock: cacheline 2
> > includes also skc_refcnt and skc_rxhash from __sk_common (I use 'pahole
> > -E ...' to get the full blown output). skc_rxhash is read for each
> > packet in inet_recvmsg()/sock_rps_record_flow() if CONFIG_RPS is set. I
> > get a cache miss per packet there and inet_recvmsg() in my test takes
> > about 8% of the whole u/s processing time.
> 
> Wait a minute, this sk->sk_rxhash should only be read on connected
> socket. Relying on it being 0 was okay only if we did not care
> of false sharing. And UDP sockets used to grab socket refcount, so we
> had false sharing a _lot_ in the past.

Thank you for the pointer.

> We must fix this if not already done properly.
> 
> Can you take care of this problem ?

I'll try, but it can be very soon: I'll have limited time and bad
internet connection up to next week.

Cheers,

Paolo
