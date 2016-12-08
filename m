From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Thu, 8 Dec 2016 19:20:44 +0000
Message-ID: <ba8de10b-5616-0fc2-6556-5029e613d498@solarflare.com>
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Tom Herbert <tom@herbertland.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:27162 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753162AbcLHTV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:21:59 -0500
In-Reply-To: <1481097428.5535.12.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/16 07:57, Paolo Abeni wrote:
> We have some experimental patches to implement GRO for plain UDP
> connected sockets, using frag_list to preserve the individual skb len,
> and deliver the packet to user space individually. With that I got
> ~3mpps with a single queue/user space sink - before the recent udp
> improvements.
You might want to benchmark these against my batched receive patches
from a while ago[1], both seem to have broadly the same objective.
In my benchmarking (obviously with different hardware) I was using
multiple sink processes, but all (processes and irqs) on a single
core; the unpatched kernel was getting ~5Mpps.  Then with my patches
I was getting ~6.4Mpps.  (Limitations of my test scripts meant that
having a single sink process meant also having a single source
process, in which case I was TX limited to ~3Mpps, and using about
60% CPU on the RX side.)

Let me know if you're interested in doing this comparison; if so I'll
post updated patches against net-next.  My own attempts to benchmark
them more have been held up by lack of time and not really knowing
what constitutes a realistic netfilter setup.
Of course if you're using a device other than sfc you'll need to add
your own equivalent of patch #2 to call the netif_receive_skb_list()
entry point from the driver.

-Ed

[1] https://www.spinics.net/lists/netdev/msg373769.html
