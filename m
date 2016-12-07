From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Tue, 06 Dec 2016 22:47:27 -0800
Message-ID: <1481093247.18162.637.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481049061.7129.18.camel@redhat.com>
         <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481051786.7129.22.camel@redhat.com>
         <1481052922.18162.605.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Tom Herbert <tom@herbertland.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35560 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbcLGGra (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 01:47:30 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so22487428pga.2
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 22:47:30 -0800 (PST)
In-Reply-To: <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 19:32 -0800, Eric Dumazet wrote:
> A follow up patch will provide a static_key (Jump Label) since most
> hosts do not even use RFS.

Speaking of static_key, it appears we now have GRO on UDP, and this
consumes a considerable amount of cpu cycles.

Turning off GRO allows me to get +20 % more packets on my single UDP
socket. (1.2 Mpps instead of 1.0 Mpps)

Surely udp_gro_receive() should be bypassed if no UDP socket has
registered a udp_sk(sk)->gro_receive handler 

And/or delay the inet_add_offload(&udpv{4|6}_offload, IPPROTO_UDP); to
the first UDP sockets setting udp_sk(sk)->gro_receive handler,
ie udp_encap_enable() and udpv6_encap_enable()


:(
