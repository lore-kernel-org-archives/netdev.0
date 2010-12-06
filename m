From: Michael Leun <lkml20100708@newton.leun.net>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (adding ipv6 address to interface)
Date: Mon, 6 Dec 2010 23:47:25 +0100
Message-ID: <20101206234725.622a2212@xenia.leun.net>
References: <20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
	<20100804153543.56f6ecad@xenia.leun.net>
	<20100804214618.GA6289@kroah.com>
	<20100805001105.5a3453ed@xenia.leun.net>
	<m1lj8l29zm.fsf@fess.ebiederm.org>
	<20100805112538.60a46cb1@xenia.leun.net>
	<m1y6clz8ta.fsf_-_@fess.ebiederm.org>
	<20100805134707.0442a7b1@xenia.leun.net>
	<20101021171532.54af5e97@xenia.leun.net>
	<20101022124858.GA719746@jupiter.n2.diac24.net>
	<20101022190532.00e9e5d8@xenia.leun.net>
	<20101024151541.161bf46c@xenia.leun.net>
	<4CFD0A8F.8010906@univ-nantes.fr>
	<m11v5uk35z.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jean-philippe.menil@univ-nantes.fr, netdev@vger.kernel.org,
	David Lamparter <equinox@diac24.net>, Greg KH <greg@kroah.com>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m11v5uk35z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 06 Dec 2010 13:22:00 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Menil Jean-Philippe <jean-philippe.menil@univ-nantes.fr> writes:
>=20
> > Le 24/10/2010 15:15, Michael Leun a =E9crit :
> >> On Fri, 22 Oct 2010 19:05:32 +0200
> >> Michael Leun<lkml20100708@newton.leun.net>  wrote:
> >>
> >>> On Fri, 22 Oct 2010 14:48:58 +0200
> >>> David Lamparter<equinox@diac24.net>  wrote:
> >>>
> >>>> On Thu, Oct 21, 2010 at 05:15:32PM +0200, Michael Leun wrote:
> >>>>> unfortunately the bug described below originally reported in
> >>>>> 2.6.35-rcX is still there in 2.6.36.
[...]
> > curiously, i'm facing a similar problem in 2.6.36.1
> >
> > in my container, when i configure ipv6 adress on the interfaces,
> > everything seems good on the first boot of the host. If i shutdown
> > my container (lxc), then boot it, i observe the following logs:
> > Dec  6 17:04:12 suntory.u06.univ-nantes.prive kernel: [  368.192019=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:04:22 suntory.u06.univ-nantes.prive kernel: [  378.432018=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:04:32 suntory.u06.univ-nantes.prive kernel: [  388.672015=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:04:42 suntory.u06.univ-nantes.prive kernel: [  398.912016=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:04:53 suntory.u06.univ-nantes.prive kernel: [  409.152016=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:05:03 suntory.u06.univ-nantes.prive kernel: [  419.392018=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:05:13 suntory.u06.univ-nantes.prive kernel: [  429.632018=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:05:23 suntory.u06.univ-nantes.prive kernel: [  439.876016=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:05:34 suntory.u06.univ-nantes.prive kernel: [  450.116015=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:05:44 suntory.u06.univ-nantes.prive kernel: [  460.356019=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:05:54 suntory.u06.univ-nantes.prive kernel: [  470.596020=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:06:04 suntory.u06.univ-nantes.prive kernel: [  480.836019=
]
> > unregister_netdevice: waiting for lo to become free. Usage count =3D=
 4
> > Dec  6 17:06:05 suntory.u06.univ-nantes.prive kernel:
> > [  481.468021] INFO: task lxc-start:3805 blocked for more than 120
> > seconds.
> >
> > Then i must reboot the host.
> > The same on kernel 2.6.34, but everything is good on a 2.6.32
> >
> > Some relvant informations about the kernel:
> > root@suntory:~# cat /boot/config-2.6.36.1-dsiun-1d | grep -i sysfs
> > # CONFIG_SYSFS_DEPRECATED_V2 is not set
> > CONFIG_ACPI_SYSFS_POWER=3Dy
> > # CONFIG_WIRELESS_EXT_SYSFS is not set
> > CONFIG_ISCSI_BOOT_SYSFS=3Dm
> > CONFIG_RTC_INTF_SYSFS=3Dy
> > CONFIG_SYSFS=3Dy
> > root@suntory:~# cat /boot/config-2.6.36.1-dsiun-1d | grep -i net_ns
> > CONFIG_NET_NS=3Dy
> >
> > Is there anything in my configuration, i must check in order to get
> > ipv6 working fully in the container?
>=20
> 2.6.37-rc4 is working here.  There were problems earlier in the
> earlier rcs. Can you try that?
>=20
> There have been a couple of different reference counting bugs between
> 2.6.34 and the present, and I haven't tracked them, just noticed they
> exist.

Can reproduce the following still on 2.6.36.1, but NOT on 2.6.37-rc4 -
so indeed seems to be fixed!


Putting an ipv6 address on a device seems to be the trigger:

OrigNS > # ip link add type veth
OrigNS > # ip link set dev veth0 up
OrigNS > # unshare -n /bin/bash
NewNS > # echo $$
<SomePID>
OrigNS > # ip link set dev veth1 netns <SomePID> # this, of course is
on a different terminal NewNS > # ip link set dev veth1 up
NewNS > # ip -6 addr add dev veth1 fd50:dead:beef::1/64
NewNS > # exit

Yields

kernel: unregister_netdevice: waiting for veth1 to become free. Usage
count =3D 3


--=20
MfG,

Michael Leun
