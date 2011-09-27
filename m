From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: Bridge stays down until a port is added
Date: Tue, 27 Sep 2011 02:28:42 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1109270224220.30860@aurora>
References: <20110811070659.GA21307@torres.zugschlus.de> <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net> <20110917204257.GA2636@torres.zugschlus.de> <1316550027.1783.102.camel@dcbw.foobar.com> <20110925082504.GA32712@torres.zugschlus.de>
 <20110926084743.35cb2ccc@nehalam.linuxnetplumber.net> <4E80DA4D.3090404@gmail.com> <20110926130507.1435d76b@nehalam.linuxnetplumber.net> <4E80F8BD.4010401@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-94995099-1317083332=:30860"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sdinet.de ([78.47.32.153]:60096 "EHLO mail.sdinet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740Ab1I0Aet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 20:34:49 -0400
In-Reply-To: <4E80F8BD.4010401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-94995099-1317083332=:30860
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 27 Sep 2011, Nicolas de Peslo=FCan wrote:

> Le 26/09/2011 22:05, Stephen Hemminger a =E9crit :
> > On Mon, 26 Sep 2011 22:02:21 +0200
> > Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
> [...]
> > > Stephen,
> > >=20
> > > What do you think about a generic per-interface option that would cau=
se
> > > bind() to accept tentative
> > > address hold by a particular interface? This of course violate IPv6
> > > principle, but we are talking
> > > about interfaces that are unable to do DAD, either permanently or unt=
il
> > > something happens on the
> > > underlying device.
> > >=20
> > > echo 1>  /sys/class/net/br0/allow_bind_on_tentative_address
> > > echo 1>  /sys/class/net/dummy0/allow_bind_on_tentative_address
> > > echo 1>  /sys/class/net/wlan0/allow_bind_on_tentative_address
> > > and so on...
> > >=20
> > > And we may possibly automatically reset this option to 0 if DAD event=
ually
> > > causes the address to be
> > > considered duplicate.
> >=20
> > The issue is that if DAD rejects a duplicate, the socket is dead and
> > application is
> > out of luck.
>=20
> Yes, and this is by design. Setting the option would state "I want to all=
ow
> early bind(), prior to DAD and I assume the fact that a possible duplicat=
e
> address will cause the corresponding socket to be dead and so the using
> application."

How about a setting just completely disabling this=20
duplicate-address-detection crap?

I do not want my servers to ever give up servicing a configured IP no=20
matter what else on the network tries to interfere.

If there are two machines using the same IP at a moment, then it may not=20
work so great, but both should have all their services up and running,=20
and once the invalid one got disconnected ("switch port down")=20
everything works - not needing to reboot the real one because some=20
daemons were not able to bind their service IPs.

c'ya
sven-haegar

--=20
Three may keep a secret, if two of them are dead.
- Ben F.
--8323328-94995099-1317083332=:30860--
