From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bridge] Bridging on broken Broadcom hardware.
Date: Wed, 18 Feb 2004 16:29:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218162904.46c1287a.davem@redhat.com>
References: <1077146945.3779.17.camel@localhost>
	<20040218161611.6365c3bf@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pschulz@foursticks.com, netdev@oss.sgi.com, sjolly@foursticks.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040218161611.6365c3bf@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 Feb 2004 16:16:11 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> This looks like a network driver not bridging problem, so forwarding to
> the netdev list.

Bridging packets, which don't come from the IP stack, won't have
CHECKSUM_HW or similar set in the SKB checksum field.  Therefore
the chip won't be told to checksum the packet on transmit.

The firmware will not mess with the packet contents at all unless
it is told to do so, and in this case (as described) it won't.

> > +	/* 5703 A2 have issues with checksumming too. (sarah) */
> > +	if (tp->pci_chip_rev_id == CHIPREV_ID_5703_A2)
> > +		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
> > +

I'd like to see a real errata report supporting such a claim.
