From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Thu, 06 Jan 2005 16:06:13 +0100
Message-ID: <1105023972.3462.48.camel@tsc-6.cph.tpack.net>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
	 <1104895169.1117.63.camel@jzny.localdomain>  <41DC0931.80603@tpack.net>
	 <1105019912.2314.20.camel@jzny.localdomain>
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
In-Reply-To: <1105019912.2314.20.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-01-06 at 14:58, jamal wrote:
> On Wed, 2005-01-05 at 10:35, Tommy Christensen wrote:
> > jamal wrote:
> 
> > 
> > Except for the drivers that call netif_stop_queue() on link-down. These
> > calls (and the corresponding netif_wake_queue) would have to be removed.
> 
> If we assume all drivers do:
> netif_stop then carrier_off then you dont need that extra check.
> Thats the working assumption i had - maybe a comment is deserving or
> we could say we dont think that all drivers are going to follow that 
> sequence.

But qdisc_restart() isn't called any more after the queue is
stopped. So how do we get to drain the packets?

Another approach could be to reset the qdisc (kind of what
dev_deactivate does) if the driver stays in queue_stopped
and carrier_off for some period of time.

-Tommy
