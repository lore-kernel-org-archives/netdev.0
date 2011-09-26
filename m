From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge stays down until a port is added
Date: Mon, 26 Sep 2011 13:05:07 -0700
Message-ID: <20110926130507.1435d76b@nehalam.linuxnetplumber.net>
References: <20110811070659.GA21307@torres.zugschlus.de>
	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	<20110917204257.GA2636@torres.zugschlus.de>
	<1316550027.1783.102.camel@dcbw.foobar.com>
	<20110925082504.GA32712@torres.zugschlus.de>
	<20110926084743.35cb2ccc@nehalam.linuxnetplumber.net>
	<4E80DA4D.3090404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46935 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622Ab1IZUFK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 16:05:10 -0400
In-Reply-To: <4E80DA4D.3090404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Sep 2011 22:02:21 +0200
Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:

> Le 26/09/2011 17:47, Stephen Hemminger a =E9crit :
> > The root of this whole problem is really that IPv6 reports addresse=
s
> > in a tentative state to applications that can not be passed to the =
bind() system call.
> > For most cases, this problem never happens because the tentative ad=
dresses are
> > resolved by Duplicate Address Detection before the application star=
ts. But
> > I have seen (and fixed) this happen before this whole discussion st=
arted.
> >
> > 1. The problem is not unique to bridges. It happens with bridge, ma=
cvtap,
> >     even on wireless networks where the device is available but car=
rier is
> >     not asserted.
> >
> > 2. Any change to what the kernel does (like not reporting tentative=
 addresses)
> >     would break applications even worse.
> >
> > 3. When the bridge was always reporting carrier, it was in effect b=
reaking
> >     IPv6 Duplicate Address Detection. And that is bad.
>=20
> Stephen,
>=20
> What do you think about a generic per-interface option that would cau=
se bind() to accept tentative=20
> address hold by a particular interface? This of course violate IPv6 p=
rinciple, but we are talking=20
> about interfaces that are unable to do DAD, either permanently or unt=
il something happens on the=20
> underlying device.
>=20
> echo 1 > /sys/class/net/br0/allow_bind_on_tentative_address
> echo 1 > /sys/class/net/dummy0/allow_bind_on_tentative_address
> echo 1 > /sys/class/net/wlan0/allow_bind_on_tentative_address
> and so on...
>=20
> And we may possibly automatically reset this option to 0 if DAD event=
ually causes the address to be=20
> considered duplicate.

The issue is that if DAD rejects a duplicate, the socket is dead and ap=
plication is
out of luck.

Has anyone looked at this issue in relation to systemd which does early
opportunistic binding of services?
