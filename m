From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Sat, 22 Mar 2003 16:34:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15996.33385.784192.430037@robur.slu.se>
References: <3E7B25AC.5030604@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3E7B25AC.5030604@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jeff Garzik writes:
 > For review by the list... The other e100/e1000 changes are in the 2.5 

 > +#ifdef CONFIG_E1000_NAPI
 > +	/* Don't disable interrupts - rely on h/w interrupt
 > +	 * moderation to keep interrupts low.  netif_rx_schedule
 > +	 * is NOP if already polling. */
 > +	netif_rx_schedule(netdev);
 > +#else


It's clean but I have some concerns...

I think this will add interrupts when resources are fully utilized.
In other words a decrease in top performance. I say "think" because I have 
no numbers. 

At GIGE rate we have ~1 k interrupts/sec using interrupt delay. (it depend 
of ring sizes etc). We are now seeing Linux boxes with ~10 GIGE interfaces. 
So any effects gets multiplied.

It makes the use zero latency RX complicated. We see Ethernet getting
used for "new" applications as SCSI, filesystems etc. In current e1000 
we just can set the desired interrupt delay and relax.

If/when PCI-X uses message signalled interrupts (MSI) we have this "un-
necessary" load over PCI too with bus arbitrations etc.


IMO believe your old plan having e1000 irq disable and with mitigation as 
default feels better but testing is needed.

Cheers.

						--ro
