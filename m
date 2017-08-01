From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] net: make net.core.{r,w}mem_{default,max} namespaced
Date: Tue, 01 Aug 2017 11:33:00 +0200
Message-ID: <1501579980.1163602.1059346360.66293F3A@webmail.messagingengine.com>
References: <20170726170333.24580-1-mcroce@redhat.com>
 <1501495652.1876.17.camel@edumazet-glaptop3.roam.corp.google.com>
 <87wp6nerrj.fsf@stressinduktion.org>
 <1501571907.1876.27.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <mcroce@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47283 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751056AbdHAJdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 05:33:01 -0400
In-Reply-To: <1501571907.1876.27.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 1, 2017, at 09:18, Eric Dumazet wrote:
> On Tue, 2017-08-01 at 02:17 -0400, Hannes Frederic Sowa wrote:
> 
> > We do account rmem as well as wmem allocated memory to the apropriate
> > mem_cgs. In theory this should be okay.
> 
> Last time I checked, rmem was not memcg ready yet.
> 
> Can you describe the details ?

As long as our packets pass __sock_queue_rcv_skb (what we do with udp,
raw, packet) we call down to sk_rmem_schedule, which in
__sk_mem_schedule -> sk_mem_raise_allocated will charge the mem_cg or
suppress the allocation.

For tcp, as I remember from the last discussion, we simply drop packets
and don't handle that very sensible, albeit we should not get out of the
mem_cg limits.

tcp_try_rmem_schedule in front of the ofo as well as the data queue
should make sure of that. Did I overlook anything?

OTOH, I am not too fond of the change. I just think that it shouldn't
deplete memory but rather stall connections.

Thanks,
Hannes
