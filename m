From: "Eble, Dan" <DanE@aiinet.com>
Subject: RE: [PATCH] (3/4) bridge linkstate handling
Date: Thu, 29 Jul 2004 09:24:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C0170D0AF1277849A4B4518034F855DD0CFC39@aiexchange.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <bridge@osdl.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>, "Stephen Hemminger" <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > This makes bridge port status reflect both the
> > state of the interface from software (up/down)
> > and the carrier.  It makes STP handle link failure
> > (cable breakage, etc).
> 
> nice. Does this entrench STP further in the kernel?
> Still planning to move it out to user space?
> 

Even if STP were implemented in user space, this part should be done in
the kernel to make sure that there is no window of time for a packet to
be received or transmitted after the link state changes.  Cable failure
is not the worst problem here.  Imagine some dunce pulling out a cable,
realizing he pulled the wrong one, and then plugging it back into the
wrong port.  If he has created a loop in the network, even a single
packet getting through can cause problems.

One could be really paranoid and flush the hardware transmit queue too.
Is there a way to do that for a port from the bridge driver?  (Or should
the device drivers do that anyway after a link change?)

Are there any ethernet controllers that can automatically disable tx/rx
after a link change, requiring the driver to reenable them?  That would
also be useful.
