From: Kevin Dwyer <kevin@pheared.net>
Subject: Re: Resend:  SIOCGIFBRDADDR?
Date: Sun, 18 Aug 2002 14:15:17 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208181407480.14268-100000@kaneda.isrd.lan>
References: <Pine.LNX.4.43.0208180910010.27516-100000@netmonster.pakint.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "Matthew G. Marsh" <mgm@paktronix.com>
In-Reply-To: <Pine.LNX.4.43.0208180910010.27516-100000@netmonster.pakint.net>
List-Id: netdev.vger.kernel.org

On Sun, 18 Aug 2002, Matthew G. Marsh grunted something like:

> > ifconfig eth0 10.5.5.8 broadcast 10.5.5.255 netmask 255.255.255.0
> > ip -f inet addr add 10.5.5.1 dev eth0 scope link
> > ip -f inet addr add 10.5.5.2 dev eth0 scope link
>
> Why do you use the 'scope link' statements?

Why do I use the 'scope link' argument, or the statement as a whole?
Those two statements give the same effect as aliases (more or less)
without having to ifconfig eth0:X for each X.  My understanding was the
'scope link' part was useful in keeping the effects of the command local
to the device.  However, I also did not generate these commands on my own:
fwbuilder is doing that.  We're trying to get a setup that can be easily
managed by other people who may not have the same experience with
command-line tools and such.

> And as far as your original question try the following:
>
> ip -f inet addr add 10.5.5.8/24 dev eth0 brd +
> ip -f inet addr add 10.5.5.1 dev eth0 scope link brd 10.5.5.255
> ip -f inet addr add 10.5.5.2 dev eth0 scope link brd 10.5.5.255

Aha!  At the suggestion of the iproute2 documentation, and another person
on the linux-ha list, I tried using 'brd +' on the aliased IPs, but
apparently we were reading the docs wrong.  Setting it explicitly works!

> And also you will then have 'ifconfig eth0':
>
> eth0      Link encap:Ethernet  HWaddr 00:C0:9F:0C:5F:DB
>           inet addr:10.5.5.2  Bcast:10.5.5.255  Mask:255.255.255.255
>           UP BROADCAST MULTICAST  MTU:1500  Metric:1
>
> Work for you?

Exactly what we need.  Now the ioctl can pull the broadcast address.

> And if I am way off base here due to jumping in just ignore me.

Not at all, thanks for the suggestion.  It seems now that I need to try to
encourage the fwbuilder folks to specify the broadcast address on each
alias.  At the very least, I should be able to whip out a patch to do
it, and hopefully they'll accept it.


/* kevin@pheared.net               http://devel.pheared.net/ */
/* Network Security Engineer       http://pheared.net/~kevin */
/* Sabotage will set us free.   Throw a rock in the machine. */
