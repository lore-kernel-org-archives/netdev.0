From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] hp100 -- fixes for new probing.
Date: Mon, 23 Feb 2004 09:49:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223094925.344bc73d@dell_ss3.pdx.osdl.net>
References: <20040223084814.80312.qmail@web14002.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Cacophonix <cacophonix@yahoo.com>
In-Reply-To: <20040223084814.80312.qmail@web14002.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 Feb 2004 00:48:14 -0800 (PST)
Cacophonix <cacophonix@yahoo.com> wrote:

> (resending, copying netdev) 
> 
> Hi,
> Any idea if any of these patches may have broken hp100 when statically built into the 
> kernel (i.e, not as a module)?
> 
> Upgrading from 2.6.0-test6 to 2.6.3-mm2 (which does include the latest patchsets for
> hp100 from Stephen), the kernel locks up at boot at the point where hp100 
> detection/initialization normally occurs (the driver is compiled into the kernel). 
> However, changing hp100 to a module, and loading it dynamically works.
> 
> Any clues about which of the recent patches between 2.6.0-test6 and 2.6.3-mm2 might
> be causing the lockup? Thanks for any pointers.
> 
> cheers,
> karthik

There probably is some bug introduced with the recent changes.  The driver tries
to handle isa, eisa, and pci all with the same infrastructure.  There are two different
probe paths, one for the module and one for the non-module ISA case.  Could you add some
printk's and see if the problem in the hp100_isa_probe code (happens first), or the
PCI probe that happens from: 
	hp100_module_init -> pci_module_init -> hp100_pci_probe...
