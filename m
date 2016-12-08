From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Thu, 08 Dec 2016 10:02:16 -0800
Message-ID: <1481220136.4930.110.camel@edumazet-glaptop3.roam.corp.google.com>
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
         <CALx6S34e_5KW3cdxS_yNXwhYuK2FQe=6+9=yTCVDsg6f2vx87g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32813 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752340AbcLHSDX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:03:23 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so27513191pgd.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 10:03:23 -0800 (PST)
In-Reply-To: <CALx6S34e_5KW3cdxS_yNXwhYuK2FQe=6+9=yTCVDsg6f2vx87g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 09:49 -0800, Tom Herbert wrote:

> Of course that would only help on systems where no one enable encaps,
> ie. looks good in the the simple benchmarks but in real life if just
> one socket enables encap everyone else takes the hit. Alternatively,
> maybe we could do early demux when we do the lookup in GRO to
> eliminate the extra lookup?

Well, if you do the lookup in GRO, wont it be done for every incoming
MSS, instead of once per GRO packet ?

Anyway, the flooded UDP sockets out there are not normally connected
ones.
