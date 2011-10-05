From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC] iproute2: add br command
Date: Wed, 05 Oct 2011 16:00:14 -0700
Message-ID: <1317855614.8950.57.camel@w-sridhar.beaverton.ibm.com>
References: <4E8BE29A.9070100@us.ibm.com>	<4E8BE63F.4020706@us.ibm.com>
	 <20111005085807.2afc2f1c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:45883 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935484Ab1JEXAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 19:00:24 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Wed, 5 Oct 2011 17:00:23 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p95N0FTk088600
	for <netdev@vger.kernel.org>; Wed, 5 Oct 2011 17:00:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p95N0FZm030159
	for <netdev@vger.kernel.org>; Wed, 5 Oct 2011 17:00:15 -0600
In-Reply-To: <20111005085807.2afc2f1c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-05 at 08:58 -0700, Stephen Hemminger wrote:
> On Tue, 04 Oct 2011 22:08:15 -0700
> Sridhar Samudrala <sri@us.ibm.com> wrote:
>=20
> >=20
> > On Tue, 2011-10-04 at 16:00 -0700, Stephen Hemminger wrote:
> > > On Tue, 04 Oct 2011 15:54:07 -0700
> > > Sridhar Samudrala<sri@us.ibm.com  <mailto:sri@us.ibm.com>>  wrote=
:
> > >
> > > >  On Tue, 2011-10-04 at 15:42 -0700, Stephen Hemminger wrote:
> > > >  >  On Wed, 5 Oct 2011 00:32:31 +0200
> > > >  >  Micha=C5=82 Miros=C5=82aw<mirqus@gmail.com  <mailto:mirqus@=
gmail.com>>  wrote:
> > > >  >
> > > >  >  >  2011/10/5 Sridhar Samudrala<sri@us.ibm.com  <mailto:sri@=
us.ibm.com>>:
> > > >  >  >  >  On Tue, 2011-10-04 at 14:07 -0700, Stephen Hemminger =
wrote:
> > > >  >  >  >>  On Tue, 04 Oct 2011 09:58:55 -0700
> > > >  >  >  >>  Andi Kleen<andi@firstfloor.org  <mailto:andi@firstfl=
oor.org>>  wrote:
> > > >  >  >  >>  >  Stephen Hemminger<shemminger@vyatta.com  <mailto:=
shemminger@vyatta.com>>  writes:
> > > >  >  >  >>  >  >  This adds a new 'br' command which is the brid=
ging equivalent of
> > > >  >  >  >>  >  >  the ip command. More of a demo of how to use n=
etlink and bridging
> > > >  >  >  >>  >  >  at this point.
> > > >  >  >  >>  >  Please name it "bridge", not "br"
> > > >  >  >  >>  Ok, but it breaks the existing pattern.
> > > >  >  >  >  Is this supposed to replace brctl utility?
> > > >  >  >  >
> > > >  >  >  >  Can we add/delete a bridge and add/delete interfaces =
to a bridge using
> > > >  >  >  >  this command?
> > > >  >  >  >
> > > >  >  >  >  If so, why not make it
> > > >  >  >  >    ip bridge add/del<brname>
> > > >  >  >  >    ip bridge addif/delif<brname>  <ifname>
> > > >  >  >
> > > >  >  >  I'll add one more idea:
> > > >  >  >
> > > >  >  >  ip link add/del<brname>  type bridge
> > > >  >  >  ip bridge add/del<brname>  <ifname>
> > > >  >  >  ip bridge fdb ...
> > > >  >
> > > >  >  In 3.0 you can already do:
> > > >  >  # ip link add dev br3 type bridge
> > This is a new syntax that i think works only for 'bridge' type.
>=20
>=20
> The bridge interface to 'ip link' is nothing special. The same syntax
> is available for macvlan, vlan, and bonding.
>=20
>=20
> > All other types require a prefix 'ip link add link'
>=20
>=20
>=20
> For vlan:
>   ip link add link eth0 name eth0.1 type vlan id 1
>=20
> The reason there is no 'link' parameter when creating a bridge is tha=
t
> the bridge is a standalone device it is not slaved to an underlying
> device.
>=20
> >=20
> > I think the ip command help text should be updated to include this =
syntax.
>=20
>=20
> patches accepted...

Will submit soon.
>=20
> >=20
> > > >  >  # ip link set dev eth3 master br3
> >=20
> > looks like the command to delete an interface from a bridge is
> >        ip link set dev eth3 nomaster
> >=20
> > Somehow this interface doesn't look all that intuitive.
>=20
> Propose something better.=20

Add eth3 to br3
ip link add link br3 [name] eth3 type brif

Delete eth3 from br3
ip link del link br3 [name] eth3 type brif

>=20
>=20
> > Currently we have 'ip route' and 'ip neigh' to manipulate routing a=
nd
> > neighbor entry tables. I think 'ip bridge' would be good way to ext=
end
> > this to support bridging.
> >=20
> > If it is not too late, can we have a interface where all bridge rel=
ated
> > commands can be done using the same prefix.
> >=20
> > I think we also should think about how this syntax can be extended =
to show
> > embedded bridges in SR-IOV NICs.
>=20
> The iproute2 commands in general try to be as close to the
> underlying netlink protocol. This makes it less user friendly but sma=
ller,
> easier to program. The only part of bridging that is special is the
> forwarding database which is similar to the neighbor table.
> If I do merge bridging into ip, it would not be as 'ip bridge' but as
> another protocol family.
>=20
>    ip -family bridge neigh ...

OK. I am not too familiar with the internal implementation details.
So i guess this may not be as straightforward as i thought.

Thanks
Sridhar
