From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Bridge stays down until a port is added
Date: Mon, 26 Sep 2011 21:56:56 +0100
Message-ID: <1317070616.2773.46.camel@bwh-desktop>
References: <20110811070659.GA21307@torres.zugschlus.de>
	 <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	 <20110917204257.GA2636@torres.zugschlus.de>
	 <1316550027.1783.102.camel@dcbw.foobar.com>
	 <20110925082504.GA32712@torres.zugschlus.de>
	 <20110926084743.35cb2ccc@nehalam.linuxnetplumber.net>
	 <4E80DA4D.3090404@gmail.com>
	 <20110926130507.1435d76b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Marc Haber <mh+netdev@zugschlus.de>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56069 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab1IZU5B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 16:57:01 -0400
In-Reply-To: <20110926130507.1435d76b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-26 at 13:05 -0700, Stephen Hemminger wrote:
> On Mon, 26 Sep 2011 22:02:21 +0200
> Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:
[...]
> > What do you think about a generic per-interface option that would c=
ause bind() to accept tentative=20
> > address hold by a particular interface? This of course violate IPv6=
 principle, but we are talking=20
> > about interfaces that are unable to do DAD, either permanently or u=
ntil something happens on the=20
> > underlying device.
> >=20
> > echo 1 > /sys/class/net/br0/allow_bind_on_tentative_address
> > echo 1 > /sys/class/net/dummy0/allow_bind_on_tentative_address
> > echo 1 > /sys/class/net/wlan0/allow_bind_on_tentative_address
> > and so on...
> >=20
> > And we may possibly automatically reset this option to 0 if DAD eve=
ntually causes the address to be=20
> > considered duplicate.
>=20
> The issue is that if DAD rejects a duplicate, the socket is dead and =
application is
> out of luck.
>=20
> Has anyone looked at this issue in relation to systemd which does ear=
ly
> opportunistic binding of services?

I think it is recommended to use the IP_FREEBIND socket option.  Which
of course is not available for IPv6.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
