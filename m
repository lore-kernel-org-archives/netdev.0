From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 19 Dec 2004 18:05:17 -0500
Message-ID: <1103497516.1046.231.camel@jzny.localdomain>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>
	 <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com, Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41C600D7.70005@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-19 at 17:29, Tommy Christensen wrote:

> I haven't tried this myself, but surely it can happen when the
> socket send-buffer is smaller than what can be queued up for
> transmission: i.e. in the qdisc queue and device DMA ring.

Shouldnt this have to do with socket options? If you wish to block while
waiting for send, then you should be allowed.
For a routing protocol that actually is notified that the link went
down, it should probably flush those socket buffer at that point.

> And even more so, when sending to multiple devices from one socket.

Yes, this looks more within reason. I dont know what the answer to this
is. But would be helpful for someone to create a setup that reproduces
this.

> > Look at e1000 they do it right there. 
> > 
> > On link up:
> > 	netif_carrier_on(netdev);
> > 	netif_wake_queue(netdev);
> > On Link Down:
> > 	netif_carrier_off(netdev); // wonder if these need swapping
> > 	netif_stop_queue(netdev);
> > 
> 
> Well, this is the same as what started this whole thread.
> I believe that stopping the queue on link-down events is simply
> bad behavior of the driver.

>From what Thomas was saying, this is not what he was doing. Read his
email.

cheers,
jamal
