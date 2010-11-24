From: Mike Caoco <caoco2002@yahoo.com>
Subject: Re: Unplug ethernet cable, the route persists.  Why?
Date: Wed, 24 Nov 2010 12:29:43 -0800 (PST)
Message-ID: <144174.46619.qm@web63401.mail.re1.yahoo.com>
References: <20101124121826.39dd6ed1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web63401.mail.re1.yahoo.com ([69.147.97.41]:41201 "HELO
	web63401.mail.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753264Ab0KXU3p convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 15:29:45 -0500
In-Reply-To: <20101124121826.39dd6ed1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--- On Wed, 11/24/10, Stephen Hemminger <shemminger@vyatta.com> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Subject: Re: Unplug ethernet cable, the route persists.  Why?
> To: "Mike Caoco" <caoco2002@yahoo.com>
> Cc: "Netdev" <netdev@vger.kernel.org>, "LKML" <linux-kernel@vger.kern=
el.org>
> Date: Wednesday, November 24, 2010, 12:18 PM
> On Wed, 24 Nov 2010 11:48:03 -0800
> (PST)
> Mike Caoco <caoco2002@yahoo.com>
> wrote:
>=20
> > Hello,
> >=20
> > This may have been discussed, but all search engines
> couldn't give me a good answer...
> >=20
> > I notice that when an interface is up/running, a local
> route is in the routing table:
> >=20
> > $ ifconfig eth1
> > eth1=A0 =A0 =A0 Link encap:Ethernet=A0
> HWaddr 00:13:20:0e:2f:ed=A0=20
> >=A0 =A0 =A0 =A0 =A0=A0=A0inet
> addr:192.168.1.125=A0 Bcast:192.168.1.255=A0
> Mask:255.255.255.0
> >=A0 =A0 =A0 =A0 =A0=A0=A0inet6
> addr: fe80::213:20ff:fe0e:2fed/64 Scope:Link
> >=A0 =A0 =A0 =A0 =A0=A0=A0UP
> BROADCAST RUNNING MULTICAST=A0 MTU:1500=A0 Metric:1
> >=A0 =A0 =A0 =A0 =A0=A0=A0RX
> packets:35984995 errors:0 dropped:0 overruns:0 frame:0
> >=A0 =A0 =A0 =A0 =A0=A0=A0TX
> packets:7409151 errors:0 dropped:0 overruns:0 carrier:0
> >=A0 =A0 =A0 =A0
> =A0=A0=A0collisions:0 txqueuelen:1000=20
> >=A0 =A0 =A0 =A0 =A0=A0=A0RX
> bytes:3252413825 (3.2 GB)=A0 TX bytes:1340077250 (1.3
> GB)
> >=20
> > $ ip route
> > 192.168.20.0/24 dev eth0=A0 proto kernel=A0
> scope link=A0 src 192.168.20.120
> > 192.168.1.0/24 dev eth1=A0 proto kernel=A0 scope
> link=A0 src 192.168.1.125=20
> > default via 192.168.20.254 dev eth1=A0 metric 100=20
> >=20
> > After I unplug the cable from eth1, the RUNNING flag
> disappears, but the route is still there:
> >=20
> > $ ifconfig eth1
> > eth1=A0 =A0 =A0 Link encap:Ethernet=A0
> HWaddr 00:13:20:0e:2f:ed=A0=20
> >=A0 =A0 =A0 =A0 =A0=A0=A0inet
> addr:192.168.1.125=A0 Bcast:192.168.1.255=A0
> Mask:255.255.255.0
> >=A0 =A0 =A0 =A0 =A0=A0=A0inet6
> addr: fe80::213:20ff:fe0e:2fed/64 Scope:Link
> >=A0 =A0 =A0 =A0 =A0=A0=A0UP
> BROADCAST MULTICAST=A0 MTU:1500=A0 Metric:1
> >=A0 =A0 =A0 =A0 =A0=A0=A0RX
> packets:35985023 errors:0 dropped:0 overruns:0 frame:0
> >=A0 =A0 =A0 =A0 =A0=A0=A0TX
> packets:7409151 errors:0 dropped:0 overruns:0 carrier:0
> >=A0 =A0 =A0 =A0
> =A0=A0=A0collisions:0 txqueuelen:1000=20
> >=A0 =A0 =A0 =A0 =A0=A0=A0RX
> bytes:3252415633 (3.2 GB)=A0 TX bytes:1340077250 (1.3
> GB)
> >=20
> > $ ip route
> > 192.168.20.0/24 dev eth0=A0 proto kernel=A0
> scope link=A0 src 192.168.20.120=20
> > 192.168.1.0/24 dev eth1=A0 proto kernel=A0 scope
> link=A0 src 192.168.1.125=20
> > default via 192.168.20.254 dev eth1=A0 metric 100=20
> >=20
> > And that *prevents* from using the default route to
> reach 192.168.1/24 subnet after eth1 is out.
> >=20
> > I looked at the code, it seems the IFF_RUNNING flag
> change is ignored in dev_change_flags():
> >=20
> > void __dev_notify_flags(struct net_device *dev,
> unsigned int old_flags)
> > {
> >=A0 =A0 =A0 =A0=A0=A0.....
> >=A0 =A0 =A0 =A0=A0=A0if
> (dev->flags & IFF_UP &&
> >=A0 =A0 =A0 =A0 =A0
> =A0=A0=A0(changes & ~(IFF_UP | IFF_PROMISC |
> IFF_ALLMULTI | IFF_VOLATILE)))
> >=A0 =A0 =A0 =A0 =A0 =A0 =A0
> =A0=A0=A0call_netdevice_notifiers(NETDEV_CHANGE,
> dev);
> > }
> >=20
> > I searched in the Internet, and saw some people
> suggest using an application listener (eg, netplug) to
> remove the route.=20
> >=20
> > My question is why cannot the kernel remove the route
> automatically when the link becomes down?=A0 Why should
> this complexity be pushed to the user to find a program to
> do that?
> >=20
>=20
> Because there is no reason for the kernel to not expect the
> link to come back.
> It is up to user space to do routing policy. For
> desktop/laptop users this is
> done typically with NetworkManager or Connman; for routers
> this is done with
> Quagga; and for servers use other tools.
>=20
> If the kernel automatically removed the route, it would
> cause routing daemons
> to recompute the route table (and propagate the change)
> every time a cable
> got pulled or NIC needed to be reset.
>=20

So if you rely on NetworkManager or Connman or Quagga to remove the rou=
te, the routing daemons will recompute the route table anyway.  So why =
cannot this be done in the kernel? =20

Even when no NetworkManager/Quagga is present, I think it is a legitima=
te reason to recompute the route when a cable is unplugged, which shoul=
d not be a frequent event unless when under error conditions.

Thanks,



     =20
