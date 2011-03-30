From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ethtool physical identify vs netlink locking?
Date: Tue, 29 Mar 2011 23:29:27 -0700
Message-ID: <20110329232927.56fb07d6@s6510>
References: <20110329135252.116bf5e0@s6510>
	<1301443676.10056.57.camel@localhost>
	<AANLkTi=um5CecqdXeqBNKHv4nWk7-bZ27aL5=bXFi0SE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54913 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753336Ab1C3G3d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 02:29:33 -0400
In-Reply-To: <AANLkTi=um5CecqdXeqBNKHv4nWk7-bZ27aL5=bXFi0SE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Mar 2011 03:35:40 +0200
Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:

> 2011/3/30 Ben Hutchings <bhutchings@solarflare.com>:
> > On Tue, 2011-03-29 at 13:52 -0700, Stephen Hemminger wrote:
> >> Right now if an administrator uses the ethtool function to identif=
y network
> >> interface, the netlink lock can be held indefinitely. In other wor=
ds, doing
> >> "ethtool -p eth1" will stop all other netlink activity. This is ba=
d, imagine
> >> the case of an operator doing that to find a NIC in a rack, and be=
cause of
> >> the netlink lockout all routing daemon activity stops.
> [...]
> >> There are several possible solutions but most involve fixing all t=
he device
> >> drivers (24). Options:
> >>
> >> 1. Have device driver drop and reacquire rtnl() while blinking
> >> 2. Have ethtool core drop rtnl before calling device driver
> >> 3. Add per-device ethtool rtnl lock
> > 4. Define a ethtool operation 'set_id_state' with an argument that =
sets
> > identification on/off/inactive/active (the last optional, for any d=
river
> > that really wants to do this differently). =C2=A0When this is defin=
ed, the
> > ethtool core runs the loop and acquires the lock each time it calls=
 this
> > operation.
>=20
> 5. Have a driver register a LED class device instead of implementing
> an ethtool op.
>=20
> Hmm. This would require changes to userspace ethtool command. I wonde=
r
> if anything else uses this call?

=46ull LED support is overkill for this I think. Especially if it means=
 creating
24 unique LED drivers.

Ben's idea seams the best so far.=20
