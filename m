From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [PATCH] METH: fix MAC address handling
Date: Sun, 6 Jan 2008 12:38:16 +0100
Message-ID: <20080106113815.GA6140@alpha.franken.de>
References: <20080105224842.78EDCC2EFB@solo.franken.de> <20080106.002305.99653155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:35912 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093AbYAFLir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2008 06:38:47 -0500
Content-Disposition: inline
In-Reply-To: <20080106.002305.99653155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 06, 2008 at 12:23:05AM -0800, David Miller wrote:
> > +	u64 macaddr;
> >  
> > -	for (i = 0; i < 6; i++)
> > -		dev->dev_addr[i] = o2meth_eaddr[i];
> >  	DPRINTK("Loading MAC Address: %s\n", print_mac(mac, dev->dev_addr));
> > -	mace->eth.mac_addr = (*(unsigned long*)o2meth_eaddr) >> 16;
> > +	macaddr = 0;
> > +	for (i = 0; i < 6; i++)
> > +		macaddr |= dev->dev_addr[i] << ((5 - i) * 8);
> > +
> > +	mace->eth.mac_addr = macaddr;
> >  }
> >  
> >  /*
> 
> Can you double-check that this conversion is equivalent.

yes, I did.

> I know that this whole driver is full of assumptions about
> the endianness of the system this chip is found on, so
> I'm only interested in if the transformation is equivalent
> and the driver will keep working properly.

I've tested the driver and it's still working :-)

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
