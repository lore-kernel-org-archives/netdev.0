From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 08 Jun 2004 16:55:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086728139.1023.71.camel@jzny.localdomain>
References: <20040608184831.GA18462@bougret.hpl.hp.com>
	 <1086722317.1023.18.camel@jzny.localdomain>
	 <20040608195238.GA21089@bougret.hpl.hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040608195238.GA21089@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-06-08 at 15:52, Jean Tourrilhes wrote:
> On Tue, Jun 08, 2004 at 03:18:37PM -0400, jamal wrote:
> > Prioritization is a subset of QoS. So if 802.11e talks prioritization,
> > thats precisely what it means - QoS.
> 
> 	Yes, it's one component of a QoS solution. But, my point is
> that on it's own, it's not enough.

There is no mapping or exclusivity of QoS to bandwidth reservation.
The most basic QoS and most popular QoS mechanisms even on Linux is 
just prioritization and nothing to do with bandwidth allocation.

> > The guy has some valid points in terms of multiple DMA rings if i
> > understood him correctly. Theres current architectural deficiencies.
> 
> 	I don't buy that. The multiple DMA ring is not the main thing
> here, all DMA transfer share the same I/O bus to the card and share
> the same memory pool, so there is no real performance gain there. The
> I/O bnandwidth to the card is vastly superior to the medium bandwidth,
> so the DMA process will never be a bottleneck.

According to Vladimir the wireless piece of it is different.
i.e each DMA ring will get different 802.11 channels 
with different backoff and contention window parameters. 
So nothing to do with the DMA process being a bottleneck.

Help me understand this better:
theres a wired side and a wireless side or are both send and receive
interafacing to the air?

> The real benefit is that the contention on the medium is
> prioritised (between contenting nodes). The contention process (CSMA,
> backoff, and all the jazz) will give a preference to stations with
> packet of the highest priority compared to stations wanting to send
> packet of lower priorities. To gain advantage of that, you only need
> to assign your packet the right priority at the driver level, and the
> CSMA will send it appropriately.

Yes, but how does the CSMA figure that? Is it not from the different
DMA rings?

> With respect to the 4 different hardware queue, you should see
> them only as an extension of the netdev queues. Basically, you just
> have a pipeline between the scheduler and the MAC which is almost a
> FIFO, but not exactly a FIFO. Those queues may do packet reordering
> between themselves, based on priorities. But at the end of the day
> they are only going to send what the scheduler is feeding them, and
> every packet the scheduler pass to those queues is eventually sent, so
> they are totally slave to the scheduler.

Is it a FIFO or there are several DMA rings involved? If the later:
when do you stop the netdevice (i.e call netif_stop_queue())? 

> 	So, I would not worry about the DMA rings. I may worry a
> little bit about packet reordering between queues, but I don't think
> it's a problem. And about the new contention behaviour, this is only
> between different stations, not within a node, so it won't impact you.

Anyone putting different packets from same flow cant guarantee ordering.

cheers,
jamal
