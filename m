From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: More 2.4.22pre10 ACPI breakage
Date: Wed, 6 Aug 2003 15:34:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E01022292E1@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Samuel Flory" <sflory@rackable.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> That said... I'm tempted to extend NAPI just a bit, to provide an 
> "always poll" mode.  It seems like all the bug reports I get 
> these days for 8139too are caused by x86 ACPI/APIC/irq routing
troubles 
> completely unrelated to the driver.  Tulip-almost-NAPI in 2.4 has an
> always-poll mode, so I have a convenient excuse :)

NAPI always-poll mode...that would be fun to play with.  JC was getting
his best results for small packets when he modified the dev e100 driver
to stay in polling mode, even if the quota wasn't met.  Basically
running without interrupts.  If there is someway for the the driver to
sample/ack the device for events when interrupts are disabled/unrouted,
then these async events can be handled in the poll routine.  I'm
thinking of events like link-status-change.

Is this what you're thinking: 1) block any place the driver enables
interrupts so interrupts stay disabled, 2) ignore netif_rx_complete so
we stay in polling mode, 3) ignore return code from netdev->poll.

For 1), the driver needs some way to know that we're in always-poll-mode
so enabling interrupts is a nop.

Just thinking out loud - haven't tried any of this.

-scott
