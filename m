From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: in-driver QoS
Date: Tue, 8 Jun 2004 12:52:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608195238.GA21089@bougret.hpl.hp.com>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <1086722317.1023.18.camel@jzny.localdomain>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1086722317.1023.18.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 08, 2004 at 03:18:37PM -0400, jamal wrote:
> On Tue, 2004-06-08 at 14:48, Jean Tourrilhes wrote:
> > Vladimir Kondratiev wrote :
> > > 
> > > In 802.11 network, there is TGe (or 802.11e), working group, developing QoS 
> > > extensions for 802.11.
> > 
> > 	802.11e is about prioritisation of the traffic, not QoS. QoS
> > is about bandwidth reservation and enforcement of policies, and
> > 802.11e does none of that.
> 
> Prioritization is a subset of QoS. So if 802.11e talks prioritization,
> thats precisely what it means - QoS.

	Yes, it's one component of a QoS solution. But, my point is
that on it's own, it's not enough.
	This means that we should not see 802.11e as a complete QoS
solution, and the center of the QoS universe, but only as a mechanism
that need to be integrated in the QoS solution. Which means, instead
of trying to fit TC in 802.11e, we need to fit 802.11e in TC. That's a
totally different perspective.

> The guy has some valid points in terms of multiple DMA rings if i
> understood him correctly. Theres current architectural deficiencies.

	I don't buy that. The multiple DMA ring is not the main thing
here, all DMA transfer share the same I/O bus to the card and share
the same memory pool, so there is no real performance gain there. The
I/O bnandwidth to the card is vastly superior to the medium bandwidth,
so the DMA process will never be a bottleneck.
	The real benefit is that the contention on the medium is
prioritised (between contenting nodes). The contention process (CSMA,
backoff, and all the jazz) will give a preference to stations with
packet of the highest priority compared to stations wanting to send
packet of lower priorities. To gain advantage of that, you only need
to assign your packet the right priority at the driver level, and the
CSMA will send it appropriately.
	With respect to the 4 different hardware queue, you should see
them only as an extension of the netdev queues. Basically, you just
have a pipeline between the scheduler and the MAC which is almost a
FIFO, but not exactly a FIFO. Those queues may do packet reordering
between themselves, based on priorities. But at the end of the day
they are only going to send what the scheduler is feeding them, and
every packet the scheduler pass to those queues is eventually sent, so
they are totally slave to the scheduler.
	So, I would not worry about the DMA rings. I may worry a
little bit about packet reordering between queues, but I don't think
it's a problem. And about the new contention behaviour, this is only
between different stations, not within a node, so it won't impact you.

> cheers,
> jamal

	Have fun...

	Jean
