From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: how to report network device errors to userspace?
Date: Wed, 19 Jun 2002 17:19:14 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D10F552.C05ADD53@nortelnetworks.com>
References: <Pine.LNX.4.33.0206191616060.1669-100000@presario>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
List-Id: netdev.vger.kernel.org

Donald Becker wrote:
> 
> On Wed, 19 Jun 2002, Chris Friesen wrote:
> 
> > I'm curious about the proper way for a network device driver to report
> > faults to userspace.
> 
> What type of fault?

I'm looking for asynchronous notification of events such as loss of ethernet
carrier or SONET LOS/LOF/LCD/RDI/AIS.  When the driver figures out (whether
interrupt or poll-based) that it's lost connectivity it then somehow notifies a
userspace app that something has happened, so the userspace app can deal with
it.

Currently the way we are doing it for ethernet is that the userspace app calls a
device ioctl() with SIOCGMIIREG multiple times per second, but it would be nice
to have the driver notify us asynchronously.

> People very much care.  There are sufficient reporting mechanisms for
> most errors -- it's much more consistent, orthogonal and thorough than
> other device types.  Compare /proc/net/dev with the errors reported for
> disks, serial, USB, keyboard...

Is it possible to select() on an entry in /proc/net becoming readable?  Is
reading from /proc/net and converting from ASCII faster than doing an ioctl() to
the driver and getting binary data?

Basically, I want a userspace app to be notified somehow by the kernel that a
link that I've expressed interest in has lost physical connectivity, and I want
to get that information as fast as possible after the event.

I've hacked a SONET driver to allow a userspace app to register its pid, which
then gets sent SIGUSR1 on critical events to tell it to use ioctl() to get the
actual information, but this is not very clean nor is it scalable.

Thanks,

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
