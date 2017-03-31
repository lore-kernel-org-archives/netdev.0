From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: use sk_protocol instead of pcflag to
 detect udplite sockets
Date: Fri, 31 Mar 2017 08:09:13 -0700
Message-ID: <1490972953.8750.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
         <1490966709.8750.7.camel@edumazet-glaptop3.roam.corp.google.com>
         <1490970784.2845.15.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35807 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755037AbdCaPJQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 11:09:16 -0400
Received: by mail-pg0-f67.google.com with SMTP id g2so17970364pge.2
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 08:09:15 -0700 (PDT)
In-Reply-To: <1490970784.2845.15.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-31 at 16:33 +0200, Paolo Abeni wrote:

> I did the above to avoid increasing the udp_sock struct size; this will
> costs more than a whole cacheline.

Yes, but who cares :)

Also note that we discussed about having a secondary receive queue in
the future, to decouple the fact that producers/consumer have to grab a
contended spinlock for every enqueued and dequeued packet.

With a secondary queue, the consumer can transfer one queue into another
in one batch.

Or simply use ptr_ring / skb_array now these infras are available thanks
to Michael.

So we will likely increase UDP socket size in a near future...

> 
> I did not hit others false sharing issues because:
> - gro_receive/gro_complete are touched only for packets coming from 
> devices with udp tunnel offload enabled, that hit the tunnel offload
> path on the nic; such packets will most probably land in the udp tunnel
>  and will not use 'forward_deficit'


> - encap_destroy is touched only socket shutdown
> - encap_rcv is protected by the 'udp_encap_needed' static key
> 
> I think this latter is problematic, so I'm ok with the patch you
> suggested.
> 
> The above change could still make sense, the udp code is already
> checking for udplite sockets with either pcflag and protocol;
> testing always the same data will make the code more cleaner.

Where are we testing sk->sk_prototocol in receive path ?

Thanks Paolo !
