From: Jim Keniston <jkenisto@us.ibm.com>
Subject: Re: Network device driver probe issues
Date: 16 Jul 2004 11:26:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090002390.1690.113.camel@localhost.localdomain>
References: <20040715135244.GD27715@krispykreme>
	 <40F71477.2020408@pobox.com>
	 <1089939860.1709.70.camel@ibm-ni9dztukfq8.beaverton.ibm.com>
	 <1089953344.23577.15.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Anton Blanchard <anton@samba.org>,
        Netdev <netdev@oss.sgi.com>, cramerj@intel.com, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, jonmason@us.ibm.com,
        Jim Keniston <jkenisto@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <1089953344.23577.15.camel@ori.thedillows.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-15 at 21:49, David Dillow wrote:
> On Thu, 2004-07-15 at 21:04, Jim Keniston wrote:
> > On Thu, 2004-07-15 at 16:34, Jeff Garzik wrote:
> [snip]
> > > > We should instead use something stable to attach to printks during
> > > > probe. pci_name() is the obvious choice, perhaps using dev_printk().
> > > > The failure then becomes:
> > > > 
> > > > 0000:01:01.0 Intel(R) PRO/1000 Network Connection
> > > > 0000:01:01.0 The EEPROM Checksum Is Not Valid
> > > > 0000:02:01.0 Intel(R) PRO/1000 Network Connection
> > > 
> > > pci_name() or a simple counter of devices found.  I prefer pci_name()
> > > 
> > > 	Jeff
> > 
> > Delay registration until the end of the probe, and make DPRINTK smarter.
> > DPRINTK should check
> > 	adapter->netdev->reg_state == NETREG_REGISTERED
> > and use the interface name (eth0) if the device is registered, or
> > pci_name() if it's not.
> > 
> > Jim
> 
> In the typhoon driver, I have tp->name, and most everything that prints
> info/errors about the card use it. During probing, it is initially set
> to point to pci_name(), and once registered, it gets pointed to
> netdev->name.
> 
> This seems fairly clean, though maybe a bit redundant.
> 
> Dave
> 

Works for me.  While we're talking about DPRINTK, e100.c could use a
similar adjustment.  e100_probe() correctly defers registration until
the probe has succeeded, but as a result, probe-time failure messages
refer to "eth%d", right?

Jim
