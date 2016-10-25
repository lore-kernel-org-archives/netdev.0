From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: fix IP_CHECKSUM handling
Date: Tue, 25 Oct 2016 13:05:21 -0700
Message-ID: <1477425921.7065.139.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477270986.7065.102.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAF=yD-+zykFwYUzhOZGcs6ywaGR3x2Qnvf1J4GYUYRf5gfTPTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Sam Kumar <samanthakumar@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Tom Herbert <tom@herbertland.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32852 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934222AbcJYUFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 16:05:23 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so20491571pfa.0
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 13:05:23 -0700 (PDT)
In-Reply-To: <CAF=yD-+zykFwYUzhOZGcs6ywaGR3x2Qnvf1J4GYUYRf5gfTPTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-25 at 15:43 -0400, Willem de Bruijn wrote:
> On Sun, Oct 23, 2016 at 9:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > First bug was added in commit ad6f939ab193 ("ip: Add offset parameter to
> > ip_cmsg_recv") : Tom missed that ipv4 udp messages could be received on
> > AF_INET6 socket. ip_cmsg_recv(msg, skb) should have been replaced by
> > ip_cmsg_recv_offset(msg, skb, sizeof(struct udphdr));
> >
> > Then commit e6afc8ace6dd ("udp: remove headers from UDP packets before
> > queueing") forgot to adjust the offsets now UDP headers are pulled
> > before skb are put in receive queue.
> >
> > Fixes: ad6f939ab193 ("ip: Add offset parameter to ip_cmsg_recv")
> > Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Sam Kumar <samanthakumar@google.com>
> > Cc: Willem de Bruijn <willemb@google.com>
> > ---
> > Tom, I would appreciate your feedback on this patch, I presume
> > you have tests to verify IP_CHECKSUM feature ? Thanks !
> >
> 
> Tested-by: Willem de Bruijn <willemb@google.com>
> 
> Thanks for fixing, Eric.
> 
> Tested with https://github.com/wdebruij/kerneltools/blob/master/tests/recv_cmsg_ipchecksum.c

Thanks a lot Willem for cooking this test !
