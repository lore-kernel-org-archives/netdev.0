From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH] Prevent "eth0: driver changed get_stats after register" lying
Date: Sat, 18 Oct 2003 21:47:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031018214749.C25375@flint.arm.linux.org.uk>
References: <20031018214622.B25375@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031018214622.B25375@flint.arm.linux.org.uk>; from rmk@arm.linux.org.uk on Sat, Oct 18, 2003 at 09:46:22PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 18, 2003 at 09:46:22PM +0100, Russell King wrote:
> There appears to be a race condition between netdev_register_sysfs
> and hotplug.  I'm seeing the message in the subject upon initialisation
> of pcnet_cs.
> 
> We set "dev->last_stats" after we have registered the class device.
> During class device registration, we trigger the hotplug scripts,
> which can in turn bring up the interface.  This in turn checks to
> see if "dev->last_stats == dev->get_stats", and, since we haven't
> set dev->last_stats yet, we complain.

Incidentally, this also means that hotplug scripts can run before
we've registered the class device attributes.  Could that be another
problem?  It's probably something that the hotplug people should
be aware of.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
