From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC] udp: some improvements on RX path.
Date: Mon, 5 Dec 2016 16:37:11 +0100
Message-ID: <20161205163711.44b01c3a@redhat.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480944138.4694.37.camel@redhat.com>
        <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Paolo Abeni <pabeni@redhat.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33994 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751127AbcLEPhP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 10:37:15 -0500
In-Reply-To: <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 05 Dec 2016 06:28:53 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2016-12-05 at 14:22 +0100, Paolo Abeni wrote:
> > 
> > On Sun, 2016-12-04 at 18:43 -0800, Eric Dumazet wrote:  
[...]

> > > But I also want to work on the idea I gave few days back, having a
> > > separate queue and use splice to transfer the 'softirq queue' into
> > > a calm queue in a different cache line.
> > > 
> > > I expect a 50 % performance increase under load, maybe 1.5 Mpps.  

I also have high hopes for such a solution. I'm very excited that you
are working on this! :-)

 
> > It should work nicely under contention, but won't that increase the
> > overhead for the uncontended/single flow scenario ? the user space
> > reader needs to acquire 2 lock when splicing the 'softirq queue'.
> > On my system ksoftirqd and the u/s process work at similar speeds,
> > so splicing will happen quite often.   
> 
> Well, the splice would happen only if you have more than one message
> in the softirq queue. So no real overhead for uncontended flow
> scenario.
> 
> 
> This reminds me of the busylock I added in __dev_xmit_skb(), which
> basically is acquired only when we detect a possible contention on
> qdisc lock.

Do you think the splice technique would, have the same performance
benefit as having a MPMC queue with separate enqueue and dequeue locking?
(like we have with skb_array/ptr_ring that avoids cache bouncing)?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
