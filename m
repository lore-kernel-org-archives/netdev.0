From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: under rx pressure, try to condense skbs
Date: Thu, 08 Dec 2016 08:08:54 -0800
Message-ID: <1481213334.4930.106.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161208104620.5fc691b8@redhat.com>
         <1481211015.4930.100.camel@edumazet-glaptop3.roam.corp.google.com>
         <de654cac-fa3c-a4e1-a24a-27187456b8d7@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34160 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbcLHQJ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 11:09:56 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so27198391pgc.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 08:09:56 -0800 (PST)
In-Reply-To: <de654cac-fa3c-a4e1-a24a-27187456b8d7@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 07:36 -0800, Rick Jones wrote:
> On 12/08/2016 07:30 AM, Eric Dumazet wrote:
> > On Thu, 2016-12-08 at 10:46 +0100, Jesper Dangaard Brouer wrote:
> >
> >> Hmmm... I'm not thrilled to have such heuristics, that change memory
> >> behavior when half of the queue size (sk->sk_rcvbuf) is reached.
> >
> > Well, copybreak drivers do that unconditionally, even under no stress at
> > all, you really should complain then.
> 
> Isn't that behaviour based (in part?) on the observation/belief that it 
> is fewer cycles to copy the small packet into a small buffer than to 
> send the larger buffer up the stack and have to allocate and map a 
> replacement?

If properly done yes ;)

Some drivers do a copybreak, but throw away the original page frag and
reallocates a fresh one anyway.

Like if you have a PAGE_SIZE=65536, it is split in ~32 frags, and
drivers might not bother trying to reuse 1 frag.
