From: Donald Becker <becker@scyld.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Fri, 3 Jan 2003 21:18:24 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301032100340.29812-100000@beohost.scyld.com>
References: <3E163CBB.30206@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, jamal <hadi@cyberus.ca>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3E163CBB.30206@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Jan 2003, Ben Greear wrote:
> Donald Becker wrote:
> 
> > It was
> >   "If you need this capability for a RESEARCH PROJECT, you can buy this
> >   specific board and thus not need to modify the kernel or device
> >   driver. "
> > 
> > You can also find a few people that want to receive specific corrupted
> > packets, change the meaning of LEDs on a NIC, and do many other strange
> > things.  But we don't need a defined kernel interface for each one.
> 
> Just out of curiosity, what is the suggested manner for adding such
> back-door hacks as this?  Maybe in a proc file system that the driver
> implements?  It would be neat to see various driver-specific features
> like this be implemented, and it would be even nicer if they followed
> at least some general guideline for how to interface with the rest of
> the world...

The problems are
 - The extensions people (very few people) want are completely unpredictable.
 - Unique features are, well, unique

You might think it's Really Very Important to change the LED meanings on
your NIC.  For instance, if one LED means all Rx traffic and another Rx
accepted you can estimate how much traffic is for you.  And most NICs
provide a way to do this.  But no two are the same, and there is no
general way to describe the semantics.  So it's a capability best
ignored.  (*)

Un

* You can access this and many other capabilities through the MII
  ioctl() interface to vendor specific register, but not as an
  abstracted, hardware-independent feature.
  Why an ioctl() and not /proc?  Exporting MII registers via /proc is
  problematic because of Sticky Bits and clear-on-read semantics.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
