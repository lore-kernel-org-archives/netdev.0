From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Tue, 8 Mar 2005 15:02:54 +0100
Message-ID: <20050308140254.GA31837@postel.suug.ch>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <20050306173145.GQ31837@postel.suug.ch> <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de> <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com> <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Andi Kleen <ak@muc.de>,
	Martin Mares <mj@ucw.cz>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
Content-Disposition: inline
In-Reply-To: <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Zdenek Radouch <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net> 2005-03-07 22:15
> The major thing the RFC misses is the fact that internal
> to one of these "public" or "private" hosts, you may have
> another, "even more private" network, for example one
> that connects the cards within the chassis.  Such network
> must be (for obvious reasons) completely hidden
> from the outside, and thus cannot come from the
> "outside" address space.  This "outside" space is a union
> of the "public" and "private" IP addresses.
> Guess what's left?  How 'bout 127.0.0.0.

RFC 1918 is in no way related to 127/8, it simply suggest various
address spaces considered private and the fact that its status
is only best practice makes it obvious that it has open issues
such as merging conflicts so I'm not quite sure if I understand
what you mean.

I think we all agree that having 127/8 fully routeable in the local
table would be a good thing although I haven't seen any use for it.

There are two major problems involved though:

  The kernel must know about its own local address for ARP, routing and
  various other reasons. This isn't a problem because it could simply
  look up the route but sometimes there is not enough information to do
  a full route lookup. This issue can be resolved with some effort though.
  It would get easier if policy routing is ignored for this purpose.

  Userspace must be told about the address and prefix of the loopback
  which is done via the LOOPBACK() macro. Extracting parts of the
  address field is not a problem if userspace is recompiled but making
  it dynamically is. It would mean to change all userspace applications
  relying on LOOPBACK() to either use netlink or ioctl. Given this
  issue has been resolved there it is still likely that certain
  userspace applications do not use LOOPBACK() and simply rely on the
  fact that 127/8 has a host scope and is _always_ looped back.

Problem #2 can probably be ignored in some cases and left to the
operator to resolve.
