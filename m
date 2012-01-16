From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: stable bonding config
Date: Mon, 16 Jan 2012 10:57:55 -0500
Message-ID: <20120116155755.GF32485@quad.redhat.com>
References: <CANj2Ebc8+Uu6gW8=Jsb42Cr2Ry88cvys-DZrkeX8Rh+uvAsRAQ@mail.gmail.com>
 <CANj2Ebf4f3o+zKMLvqiVGyMegdJiqUzVupkOLuKqmxuaVSTdyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752140Ab2APP5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jan 2012 10:57:48 -0500
Content-Disposition: inline
In-Reply-To: <CANj2Ebf4f3o+zKMLvqiVGyMegdJiqUzVupkOLuKqmxuaVSTdyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2012 at 09:52:25PM -0500, Simon Chen wrote:
> I am using the following:
>=20
> Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
> ixgbe 3.7.17 driver (latest from intel)
>=20
> Thanks.
> -Simon
>=20

Use the module option to disable RSC and I think it will work.

> On Thu, Jan 12, 2012 at 9:31 PM, Simon Chen <simonchennj@gmail.com> w=
rote:
> > Hi all,
> >
> > Not sure if this is the right place to ask, but I got very good
> > answers about this topic in the past...
> >
> > I am mostly using Ubuntu 10.10. Each server has dual intel 10G NICs=
,
> > which I want to bond. I configured the switches to support 802.3ad.
> > Based on this post http://ubuntuforums.org/showthread.php?t=3D15951=
77, I
> > configure the server as:
> >
> > /home/simon# cat /etc/modprobe.d/aliases.conf
> > alias bond0 bonding
> > options bonding mode=3D4 miimon=3D100 lacp_rate=3D1 downdelay=3D200
> > updelay=3D200 ad_select=3D1 xmit_hash_policy=3D1
> >
> > /home/simon# cat /etc/network/interfaces
> > ...
> > auto bond0
> > iface bond0 inet manual
> > =A0 =A0 =A0 =A0bond-slaves none
> > =A0 =A0 =A0 =A0bond-mode 4
> > =A0 =A0 =A0 =A0bond-miimon 100
> > =A0 =A0 =A0 =A0up /sbin/ifenslave bond0 eth2 eth3
> > =A0 =A0 =A0 =A0down /sbin/ifenslave bond0 eth2 eth3
> >
> > auto eth2
> > iface eth2 inet manual
> > bond-master bond0
> > bond-primary eth2 eth3
> >
> > auto eth3
> > iface eth3 inet manual
> > bond-master bond0
> > bond-primary eth2 eth3
> >
> > auto bond0.200
> > iface bond0.200 inet static
> > =A0address ...
> > =A0vlan_raw_device bond0
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
> >
> > However, after a reboot the bonding doesn't work immediately. In pa=
rticular:
> >
> > /home/simon# cat /proc/net/bonding/bond0
> > ...
> > 802.3ad info
> > LACP rate: fast
> > Aggregator selection policy (ad_select): bandwidth
> > Active Aggregator Info:
> > =A0 =A0 =A0 =A0Aggregator ID: 3
> > =A0 =A0 =A0 =A0Number of ports: 2
> > =A0 =A0 =A0 =A0Actor Key: 33
> > =A0 =A0 =A0 =A0Partner Key: 19
> > =A0 =A0 =A0 =A0Partner Mac Address: 00:00:00:00:00:00 <------bondin=
g not working
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > The only magic to get it work that I know of, is to perform "rmmod
> > ixgbe" "modprobe ixgbe" and then "ifconfig eth2 0.0.0.0 up" "ifconf=
ig
> > eth3 0.0.0.0 up" "ifdown bond0" "ifup bond0".
> >
> > Is there a hassle-free bonding configuration that I can use? Or som=
e
> > trick that I am not aware of?
> >
> > Thanks.
> > -Simon
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
