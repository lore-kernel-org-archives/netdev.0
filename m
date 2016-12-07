From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Wed, 07 Dec 2016 06:26:31 -0800
Message-ID: <1481120791.4930.4.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34168 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbcLGO0d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 09:26:33 -0500
Received: by mail-pg0-f67.google.com with SMTP id e9so23619651pgc.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 06:26:33 -0800 (PST)
In-Reply-To: <1481097428.5535.12.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 08:57 +0100, Paolo Abeni wrote:
> On Tue, 2016-12-06 at 22:47 -0800, Eric Dumazet wrote:
> > On Tue, 2016-12-06 at 19:32 -0800, Eric Dumazet wrote:
> > > A follow up patch will provide a static_key (Jump Label) since most
> > > hosts do not even use RFS.
> > 
> > Speaking of static_key, it appears we now have GRO on UDP, and this
> > consumes a considerable amount of cpu cycles.
> > 
> > Turning off GRO allows me to get +20 % more packets on my single UDP
> > socket. (1.2 Mpps instead of 1.0 Mpps)
> 
> I see also an improvement for single flow tests disabling GRO, but on a
> smaller scale (~5% if I recall correctly).

Was it on a NUMA host ?

My tests are spreading packets on 8 RX queues, 50/50 split on two NUMA
nodes.
