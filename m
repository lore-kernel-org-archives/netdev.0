From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (1/11) Irda dongle module owner support (revised)
Date: Fri, 3 Oct 2003 10:31:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003173131.GB14313@bougret.hpl.hp.com>
References: <20031002152026.4bfd2c67.shemminger@osdl.org> <20031002233335.GA7945@bougret.hpl.hp.com> <20031003102133.2e5a41a2.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031003102133.2e5a41a2.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 03, 2003 at 10:21:33AM -0700, Stephen Hemminger wrote:
> Revised version of the dongle module owner patch, incorporating Jean's comments.
> This replaces the original patch.  It provides an owner field an appropriate 
> ref counting for IRDA dongles.
> 
> Changes since list version:
> 	s/dongle_lock/dongles->hb_spinlock/
> 	get lock on device_cleanup
> 	replace ASSERT() about in_interrupt with might_sleep().

	Perfect ! Thanks for the quick turnaround, and sorry for the
extra work.

> In case your curious about locking, the callers are:
> 	module_init -> irda_device_init
> 	module_exit -> irda_device_cleanup
> 	irport_net_ioctl -> irda_device_dongle_init
> 	module_init -> XXX_dongle_init -> irda_device_register_dongle
> 	module_exit -> XXX_dongle_exit -> irda_device_unregister_dongle
> 
> In other words, no interrupt or BH access to the dongle list.
> Obviously, hashing this list is overkill,

	Ok.

> but "when in Rome"...

	Eat some pasta ?
	Maintaining others people code is very much like archeological
excavation, sometimes you find treasures buried in the various
stratas, but most of the time...

	Have fun...

	Jean
