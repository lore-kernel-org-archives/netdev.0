From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Fwd: pcmcia ether drivers can't be unloaded]
Date: Tue, 27 Jul 2004 17:19:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040727171929.17858c7b.davem@redhat.com>
References: <41068BEF.7010200@pobox.com>
	<20040727233614.B30782@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, shemminger@osdl.org, netdev@oss.sgi.com, greg@kroah.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk@arm.linux.org.uk>
In-Reply-To: <20040727233614.B30782@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 27 Jul 2004 23:36:14 +0100
Russell King <rmk@arm.linux.org.uk> wrote:

> > One fix is to not set owner field but then there is a hot plug/module
> > remove race. But the right fix seems to fix up pcmcia to be a true bus
> > in the driver model and have the same hotplug as other buses; usb and
> > pci don't have the problem.
> 
> No, the right fix is not to try to fsck with PCMCIA refcounting - it
> isn't up to having drivers randomly unloaded.  IOW, it remains 2.4
> behaviour.

I totally disagree.  This is a bogus argument for two reasons:

1) If the PCMCIA layer can handle cards popping out at any time,
   physically, it is illogical to handicap it on the software
   side in terms of this.

2) There is no way I can stomache "some" networking cards not being
   able to have their modules yanked at any point in time.

   An enormous amount of effort has gone into making networking
   devices and drivers yankable regardless of how configured they
   are and what resources are attached to it.

You have to be kidding me to say that the one subsystem that should
handle hot plugging of stuff the best (PCMCIA) can't handle something
that all of our "normal" PCI and USB drivers can?

The fact is this, device unload of an arbitrary network driver should
work at any point in time, and succeed unloading within a second or
two.  Anything else is a bug.
