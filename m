From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Ping Is Broken
Date: Mon, 12 Oct 2009 22:43:34 +0200
Message-ID: <20091012204334.GA3431@del.dom.local>
References: <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com>
 <20091012094752.GA8114@ff.dom.local>
 <7e84ed60910121214n71413383v3ee703ea6042f355@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: CentOS mailing list
	<public-centos-IFYaIzF+flcdnm+yROfE0A@plane.gmane.org>,
	public-netdev-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org,
	Omaha Linux User Group
	<public-olug-u8lKhlSLHjY@plane.gmane.org>
To: Rob Townley <rob.townley@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:39388 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756937AbZJLUoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2009 16:44:22 -0400
Received: from public by plane.gmane.org with local (Exim 4.63)
	(envelope-from <public@plane.gmane.org>)
	id 1MxRk8-0006H0-Uv
	for netdev@vger.kernel.org; Mon, 12 Oct 2009 22:43:44 +0200
Content-Disposition: inline
In-Reply-To: <7e84ed60910121214n71413383v3ee703ea6042f355@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, Oct 12, 2009 at 02:14:13PM -0500, Rob Townley wrote:
> On Mon, Oct 12, 2009 at 4:47 AM, Jarek Poplawski <jarkao2@gmail.com> =
wrote:
> >
> >
> > On 09-10-2009 18:44, Rob Townley wrote:
> >> ping -I is broken
> >>
> >> The following deals with bug in ping that made it very difficult t=
o set up a
> >> system with two gateways.
> >>
> >> Demonstration that *ping -I is broken*. When specifying the source
> >> interface using -I with an *ethX* alias and that interface is not =
the
> >> default gateway
> >> interface, then ping fails. When specifying the interface as an ip=
 address,
> >> ping works. Search for "Destination Host Unreachable" to find the =
bug.
> >>
> >>
> >> eth*0* =3D 4.3.2.8 and the default gateway is accessed through a d=
ifferent
> >> interface eth*1*.
> >> eth*1* =3D 192.168.168.155 is used as the device to get to the def=
ault
> >> gateway.
> >> *FAILS *: ping *-I eth0* 208.67.222.222
> >> *WORKS*: ping *-I 4.3.2.8* 208.67.222.222
> >> *WORKS*: ping *-I eth1* 208.67.222.222
> >> *WORKS*: ping *-I 192.168.168.155* 208.67.222.222
> > ...
> >> man ping:
> >> =A0 =A0-I interface address
> >> =A0 =A0 =A0 =A0 Set source address to specified interface address.
> >> =A0 =A0 =A0 =A0 Argument may be *numeric IP address or name of dev=
ice*.
> >> =A0 =A0 =A0 =A0 When =A0pinging =A0IPv6 =A0link-local =A0address =A0=
this option is required.
> >
> > It seems this description might be misleading that IP address and n=
ame
> > of device are equivalent here, while they are treated a bit differe=
nt.
> > The device name is additionally used in a sendmsg message, probably=
 to
> > guarantee the device is really used (not its address only), so it
> > looks like intended.
> >
> >> ping -V returns the latest available on CentOS and Fedora and the
> >> maintainers website:
> >> ping utility, iputils-ss020927
> >
> > I guess the patch below could do what you expect in this case, but
> > rather "man" should be fixed...
>=20
> Thank you for the patch.  i will test it. i was trying to find the
> problem using gdb and figure out a patch myself.
>=20
> ping used to work the way i expected many many years ago on various
> *nix systems.

This patch is rather to show the main difference a device name could
make here. IMHO it should work in your case (I didn't test it), but
as a matter of fact I'm not sure it's the way (route) you expected.

> Besides, traceroute is broken by the same problem except that
> traceroute is much more explicit with a -i and -s parameters.  Who
> knows what else is broken by all the meddling in interface name
> aliases without testing.
>=20
> MultiNic / MultiGatewayed machines are hard enough in Linux, lets not
> give users a reason to use BSD or Windows.

Linux routing, especially multipath, might be simply different than
others, but I wouldn't call it broken (except when it's broken ;-).
In this case I don't think it's proven enough: if you change the
default route to eth0's in your example it should show there is some
consistency in it.

It seems "-I eth0" should mean something else than "-I ip_address"
yet (where it can matter), and ping does it. It's only not documented
enough.

Jarek P.

