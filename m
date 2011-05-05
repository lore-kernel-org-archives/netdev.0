From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Thu, 5 May 2011 16:27:24 +0530
Message-ID: <OF5EA83199.F80E6CDA-ON65257887.003927A7-65257887.003BF233@in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com> <20110504144622.GA15823@redhat.com> <OFAEA8C363.C13C507B-ON65257886.0051F71F-65257886.0052217F@in.ibm.com> <20110504212359.GA21446@redhat.com> <OF2E0182A1.3818A07E-ON65257887.00225EE8-65257887.002C000C@in.ibm.com> <20110505090439.GD17647@redhat.com> <OF057406D7.B63B52F4-ON65257887.00344787-65257887.003532EF@in.ibm.com> <20110505101229.GA28690@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110505101229.GA28690@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/05/2011 03:42:29 PM:

> > > > It shows that 2.9% of the time, the 1 jiffy was not enough
> > > > to free up space in the txq.
> > >
> > > How common is it to free up space in *less than* 1 jiffy?
> >
> > True,
>
> Sorry, which statement do you say is true? That interrupt
> after less than 1 jiffy is common?

I meant to say that, 97% of the time, space was enough for
the next xmit to succeed. This is keeping in mind that on
average 43 slots were freed up, indicating that the guest
was not waiting around for too long.

Regarding whether interrupts in less than 1 jiffy is
common, I think most of the time it should. But
increasing the limit as to when to do the cb would
increase to a jiffy.

To confirm, I just put some counters in the original
code and found that interrupts happen in less than a
jiffy around 96.75% of the time, only 3.25% took 1
jiffy. But as expected, this is with the host
interrupting immediately, which leads to many
stop/start/interrupts due to very little free capacity.

> > but the point is that the space freed is just
> > enough for 43 entries, keeping it lower means a flood
> > of (psuedo) stop's and restart's.

> Better yet, here they are in git:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-
> net-next-event-idx-v1
> git://git.kernel.org/pub/scm/linux/kernel/git/mst/qemu-kvm.git
> virtio-net-event-idx-v1

Great, I will pick up from here.

thanks,

- KK

