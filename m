From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge stays down until a port is added
Date: Mon, 26 Sep 2011 17:43:19 -0700
Message-ID: <20110926174319.0fa59e1f@nehalam.linuxnetplumber.net>
References: <20110811070659.GA21307@torres.zugschlus.de>
	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	<20110917204257.GA2636@torres.zugschlus.de>
	<1316550027.1783.102.camel@dcbw.foobar.com>
	<20110925082504.GA32712@torres.zugschlus.de>
	<20110926084743.35cb2ccc@nehalam.linuxnetplumber.net>
	<4E80DA4D.3090404@gmail.com>
	<20110926130507.1435d76b@nehalam.linuxnetplumber.net>
	<4E80F8BD.4010401@gmail.com>
	<alpine.DEB.2.02.1109270224220.30860@aurora>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>, Marc Haber <mh+netdev@zugschlus.de>,
	netdev@vger.kernel.org
To: Sven-Haegar Koch <haegar@sdinet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44464 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788Ab1I0AnW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 20:43:22 -0400
In-Reply-To: <alpine.DEB.2.02.1109270224220.30860@aurora>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Sep 2011 02:28:42 +0200 (CEST)
Sven-Haegar Koch <haegar@sdinet.de> wrote:

> On Tue, 27 Sep 2011, Nicolas de Peslo=FCan wrote:
>=20
> > Le 26/09/2011 22:05, Stephen Hemminger a =E9crit :
> > > On Mon, 26 Sep 2011 22:02:21 +0200
> > > Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
> > [...]
> > > > Stephen,
> > > >=20
> > > > What do you think about a generic per-interface option that wou=
ld cause
> > > > bind() to accept tentative
> > > > address hold by a particular interface? This of course violate =
IPv6
> > > > principle, but we are talking
> > > > about interfaces that are unable to do DAD, either permanently =
or until
> > > > something happens on the
> > > > underlying device.
> > > >=20
> > > > echo 1>  /sys/class/net/br0/allow_bind_on_tentative_address
> > > > echo 1>  /sys/class/net/dummy0/allow_bind_on_tentative_address
> > > > echo 1>  /sys/class/net/wlan0/allow_bind_on_tentative_address
> > > > and so on...
> > > >=20
> > > > And we may possibly automatically reset this option to 0 if DAD=
 eventually
> > > > causes the address to be
> > > > considered duplicate.
> > >=20
> > > The issue is that if DAD rejects a duplicate, the socket is dead =
and
> > > application is
> > > out of luck.
> >=20
> > Yes, and this is by design. Setting the option would state "I want =
to allow
> > early bind(), prior to DAD and I assume the fact that a possible du=
plicate
> > address will cause the corresponding socket to be dead and so the u=
sing
> > application."
>=20
> How about a setting just completely disabling this=20
> duplicate-address-detection crap?
>

Already multiple ways to disable it:
  1. Set /proc/sys/net/ipv6/XXX/accept_dad to 0
  2. Set flag when assigning address with 'ip add add ... nodad'=20
  3. Set IFF_NOARP on the interface (done by drivers)
