From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [Fwd: pcmcia ether drivers can't be unloaded]
Date: Tue, 27 Jul 2004 23:36:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040727233614.B30782@flint.arm.linux.org.uk>
References: <41068BEF.7010200@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, shemminger@osdl.org, davem@redhat.com,
        netdev@oss.sgi.com, Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <41068BEF.7010200@pobox.com>; from jgarzik@pobox.com on Tue, Jul 27, 2004 at 01:07:59PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 27, 2004 at 01:07:59PM -0400, Jeff Garzik wrote:
> It looks like pcmica modular ether (example orinoco) can never be manually
> unloaded because module refcount is always 1. This comes from the owner
> field in the pcmcia_driver.owner being set.

Intended behaviour.  As long as the driver is bound to a socket, there are
references to the driver, so we need to keep the refcount non-zero.

Once the driver is unbound (by ejecting cards) then the ref count will
drop to zero and the module can be unloaded.

> One fix is to not set owner field but then there is a hot plug/module
> remove race. But the right fix seems to fix up pcmcia to be a true bus
> in the driver model and have the same hotplug as other buses; usb and
> pci don't have the problem.

No, the right fix is not to try to fsck with PCMCIA refcounting - it
isn't up to having drivers randomly unloaded.  IOW, it remains 2.4
behaviour.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
