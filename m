From: Andi Kleen <ak@suse.de>
Subject: Re: how to report network device errors to userspace?
Date: Wed, 19 Jun 2002 23:36:59 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020619233659.A7368@wotan.suse.de>
References: <Pine.LNX.4.33.0206191616060.1669-100000@presario> <3D10F552.C05ADD53@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Donald Becker <becker@scyld.com>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Content-Disposition: inline
In-Reply-To: <3D10F552.C05ADD53@nortelnetworks.com>
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2002 at 05:19:14PM -0400, Chris Friesen wrote:
> Donald Becker wrote:
> > 
> > On Wed, 19 Jun 2002, Chris Friesen wrote:
> > 
> > > I'm curious about the proper way for a network device driver to report
> > > faults to userspace.
> > 
> > What type of fault?
> 
> I'm looking for asynchronous notification of events such as loss of ethernet
> carrier or SONET LOS/LOF/LCD/RDI/AIS.  When the driver figures out (whether
> interrupt or poll-based) that it's lost connectivity it then somehow notifies a
> userspace app that something has happened, so the userspace app can deal with
> it.
> 
> Currently the way we are doing it for ethernet is that the userspace app calls a
> device ioctl() with SIOCGMIIREG multiple times per second, but it would be nice
> to have the driver notify us asynchronously.

I would suggest sending a netlink message from the driver.  That's really
what netlink was designed for.

> 
> > People very much care.  There are sufficient reporting mechanisms for
> > most errors -- it's much more consistent, orthogonal and thorough than
> > other device types.  Compare /proc/net/dev with the errors reported for
> > disks, serial, USB, keyboard...
> 
> Is it possible to select() on an entry in /proc/net becoming readable?  Is

Yes, but it's very ugly to implement and not recommended.

> reading from /proc/net and converting from ASCII faster than doing an ioctl() to
> the driver and getting binary data?

It's quite slow. When you plan to do this often better go with some 
binary interface (experience has shown for other statistics that /proc
has a huge overhead) 


-Andi
