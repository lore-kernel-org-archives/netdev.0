From: steve@chygwyn.com
Subject: Re: [PATCH 07/10] decnet: use RCU to find network devices
Date: Tue, 10 Nov 2009 18:24:36 +0000
Message-ID: <20091110182436.GA13374@fogou.chygwyn.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.615305929@vyatta.com> <4AF9B449.6040708@gmail.com> <20091110105053.16687e93@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Christine Caulfield <christine.caulfield@googlemail.com>,
	Hannes Eder <hannes@hanneseder.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Steven Whitehouse <swhiteho@redhat.com>,
	netdev@vger.kernel.org, linux-decnet-users@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:55657 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309AbZKJTaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 14:30:00 -0500
Content-Disposition: inline
In-Reply-To: <20091110105053.16687e93@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Nov 10, 2009 at 10:50:53AM -0800, Stephen Hemminger wrote:
> On Tue, 10 Nov 2009 19:43:21 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Stephen Hemminger a =E9crit :
> > > When showing device statistics use RCU rather than read_lock(&dev=
_base_lock)
> > > Compile tested only.
> > >=20
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > >=20
> > > --- a/net/decnet/dn_dev.c	2009-11-10 09:30:55.557376454 -0800
> > > +++ b/net/decnet/dn_dev.c	2009-11-10 09:40:03.847005394 -0800
> > > @@ -856,9 +856,7 @@ int dn_dev_bind_default(__le16 *addr)
> > >  	dev =3D dn_dev_get_default();
> > >  last_chance:
> > >  	if (dev) {
> > > -		read_lock(&dev_base_lock);
> > >  		rv =3D dn_dev_get_first(dev, addr);
> > > -		read_unlock(&dev_base_lock);
> > >  		dev_put(dev);
> > >  		if (rv =3D=3D 0 || dev =3D=3D init_net.loopback_dev)
> > >  			return rv;
> > > @@ -1323,18 +1321,18 @@ static inline int is_dn_dev(struct net_d
> >=20
> >=20
> > I dont understand this part. Why previous locking can be avoided ?
>=20
> dn_dev_get_default acquires a reference on dev so the device can
> not go away.
>=20
> It could be the original author meant to ensure the address list
> doesn't change. If so, then rtnl_lock() should have been used.

The original author has tried to remember what he was thinking when
he wrote this code :-)

I think you are right that it should be rtnl_lock() as we don't want
the address list changing at this point. On the other hand I notice
also that other bits of the code seem to be using dev_base_lock too.

Maybe this is a hang over from another era? I'll have to refresh
my memory some more before I can give a verdict on that I'm afraid,

Steve.

