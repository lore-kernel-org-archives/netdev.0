From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Tue, 9 Nov 2010 22:54:57 +0530
Message-ID: <OFFE63B7F4.D491BE12-ON652577D6.005B4090-652577D6.005F565A@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101026085709.GC23530@redhat.com> <OF529E89EE.84DB37B8-ON652577D6.001665CF-652577D6.00192784@in.ibm.com> <20101109132239.GF22705@redhat.com> <OF24E08752.2087FFA4-ON652577D6.00532DF1-652577D6.0054B291@in.ibm.com> <20101109153325.GB26153@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:52911 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab0KIRV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 12:21:26 -0500
In-Reply-To: <20101109153325.GB26153@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 11/09/2010 09:03:25 PM:

> > > Something strange here, right?
> > > 1. You are consistently getting >10G/s here, and even with a single
> > stream?
> >
> > Sorry, I should have mentioned this though I had stated in my
> > earlier mails. Each test result has two iterations, each of 60
> > seconds, except when #netperfs is 1 for which I do 10 iteration
> > (sum across 10 iterations).
>
> So need to divide the number by 10?

Yes, that is what I get with 512/1K macvtap I/O size :)

> >  I started doing many more iterations
> > for 1 netperf after finding the issue earlier with single stream.
> > So the BW is only 4.5-7 Gbps.
> >
> > > 2. With 2 streams, is where we get < 10G/s originally. Instead of
> > >    doubling that we get a marginal improvement with 2 queues and
> > >    about 30% worse with 1 queue.
> >
> > (doubling happens consistently for guest -> host, but never for
> > remote host) I tried 512/txqs=2 and 1024/txqs=8 to get a varied
> > testing scenario. In first case, there is a slight improvement in
> > BW and good reduction in SD. In the second case, only SD improves
> > (though BW drops for 2 stream for some reason).  In both cases,
> > BW and SD improves as the number of sessions increase.
>
> I guess this is another indication that something's wrong.

The patch - both virtio-net and vhost-net, doesn't have any
locking/mutex's/ or any synchronization method. Guest -> host
performance improvement of upto 100% shows the patch is not
doing anything wrong.

> We are quite far from line rate, the fact BW does not scale
> means there's some contention in the code.

Attaining line speed with macvtap seems to be a generic issue
and unrelated to my patch specifically. IMHO if there is nothing
wrong in the code (review) and is accepted, it will benefit as
others can also help to find what needs to be implemented in
vhost/macvtap/qemu to get line speed for guest->remote-host.

PS: bare-metal performance for host->remote-host is also
    2.7 Gbps and 2.8 Gbps for 512/1024 for the same card.

Thanks,

- KK

