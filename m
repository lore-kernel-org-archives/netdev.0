From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Fri, 07 Jan 2005 16:26:45 +0100
Message-ID: <1105111605.3462.101.camel@tsc-6.cph.tpack.net>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
	 <1104895169.1117.63.camel@jzny.localdomain>  <41DC0931.80603@tpack.net>
	 <1105019912.2314.20.camel@jzny.localdomain>
	 <1105023972.3462.48.camel@tsc-6.cph.tpack.net>
	 <1105104757.1046.63.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1105104757.1046.63.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-07 at 14:32, jamal wrote:
> On Thu, 2005-01-06 at 10:06, Tommy Christensen wrote:
> 
> > But qdisc_restart() isn't called any more after the queue is
> > stopped. So how do we get to drain the packets?
> 
> We return -1; so qdisc restart will be called until theres no packets
> left on the queue. Did i miss something in the state machine there?

Yes, qdisc_run does this
  while (!netif_queue_stopped(dev) && qdisc_restart(dev) < 0)
    /* NOTHING */;

> > Another approach could be to reset the qdisc (kind of what
> > dev_deactivate does) if the driver stays in queue_stopped
> > and carrier_off for some period of time.
> > 
> 
> reseting qdisc could certainly be part of the device watchdog.
> Note that once the packets are drained, the next thing that will happen
> if device is stopped for a dev->timeout period is watchdog kicking in
> and flushing the DMA. So you could reset your qdisc there though i am
> not sure it will be needed with that patch.

Unfortunately the watchdog won't do this when carrier is off, which
is fair enough since the chip isn't hung as such.

So, we would need another method to flush out stale packets from
the DMA ring. Some drivers already do this themselves, and some won't
need it because they keep on running even when link is down.

-Tommy
