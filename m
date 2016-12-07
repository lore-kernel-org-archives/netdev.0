From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Wed, 07 Dec 2016 06:29:16 -0800
Message-ID: <1481120956.4930.7.camel@edumazet-glaptop3.roam.corp.google.com>
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
         <1481093247.18162.637.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481097428.5535.12.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Tom Herbert <tom@herbertland.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33582 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932193AbcLGO3c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 09:29:32 -0500
Received: by mail-pf0-f194.google.com with SMTP id 144so20719712pfv.0
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 06:29:18 -0800 (PST)
In-Reply-To: <1481097428.5535.12.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 08:57 +0100, Paolo Abeni wrote:

> We have some experimental patches to implement GRO for plain UDP
> connected sockets, using frag_list to preserve the individual skb len,
> and deliver the packet to user space individually. With that I got
> ~3mpps with a single queue/user space sink - before the recent udp
> improvements. I would like to present these patches on netdev soon (no
> sooner than next week, anyway).
> 

Make sure you handle properly all netfilter helpers :(

Keeping frag_list means you keep one sk_buff per segment, so this really
looks like a legacy UDP server (like a DNS server) wont benefit from
this anyway.
