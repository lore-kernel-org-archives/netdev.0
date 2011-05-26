From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Thu, 26 May 2011 09:38:03 -0400
Message-ID: <20110526133803.GA12617@hmsreliant.think-freely.org>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
 <20110523151336.GF21309@gospo.rdu.redhat.com>
 <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
 <20110524150340.GH21309@gospo.rdu.redhat.com>
 <BANLkTi=UCH8+ZVFwZ96YvFuDqDLwq8ihkQ@mail.gmail.com>
 <20110525150144.GB11867@hmsreliant.think-freely.org>
 <BANLkTimEFg0Q=12z2_R4NNQ_VjRH=qhp2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46373 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757360Ab1EZNiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 09:38:19 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTimEFg0Q=12z2_R4NNQ_VjRH=qhp2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2011 at 05:11:35PM +0800, Am=E9rico Wang wrote:
> On Wed, May 25, 2011 at 11:01 PM, Neil Horman <nhorman@tuxdriver.com>=
 wrote:
> > While thats a fine rule to draw a distinction on, it also creates o=
ther
> > organizational oddities. =A0By this reasoning, the loopback/tun-tap=
 and xen
> > netfront drivers should also be moved to /net. =A0While this might =
be an ok move
> > to make, I think we can all agree, that while they don't touch spec=
ific
> > hardware, they implement instances of the driver model, and as such=
 are
> > reasonably placed in /drivers.
> >
>=20
> Hmm, after reading Andy's comments again, I think his point is
> probably bridge has STP management code which makes a difference
> with bonding, but you know, we have 802.3ad in bonding too.
>=20
Ok, pppe, slip, localtalk and wireless have code that, strictly speakin=
g have
non-driver code in them to, should they also be moved to /net?=20

You seem stuck on this notion that theres a rule that squarely places c=
ode in
/net or /drivers.  Nominally the choice is obvious, but in several case=
s, such
as this, its simply not.  You have valid reasons for asserting bonding =
should be
in /net.  There are just as many that assert it should be in /drivers.=20

> > This is really a false assertion. =A0Theres nothing more or less ha=
rd about
> > finding bonding code in /drivers than there is in /net. =A0grep and=
 find let you
> > locate the code in either place equally well, and cscope really mak=
es it all
> > moot anyway.
> >
>=20
> Sometimes cscope sucks, especially when you meet function pointers
> which are pretty common in net code. When I grep netpoll code, I have=
 to
> do `grep ndo_netpoll_setup -nr net/  drivers/net`, if bonding were in=
 net/
> `grep -nr net/` is enough. 'netdev_rx_handler_register' too.
>=20
Yes, sometimes cscope sucks.  moving this code won't fix that.  And if =
the major
advantage to this move is that you can remove a directory from a grep c=
ommand,
thats really no advantage at all.  To further illustrate this point, do=
es the
fact that I could do this:
grep register_netdev\( -nr /drivers/net
instead of=20
grep register_netdev\( -nr /net /drivers/net=20
Justify the movement of the bridging code to /drivers?  Of course not.

Neil
