From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: add br command
Date: Wed, 5 Oct 2011 08:58:07 -0700
Message-ID: <20111005085807.2afc2f1c@nehalam.linuxnetplumber.net>
References: <4E8BE29A.9070100@us.ibm.com>
	<4E8BE63F.4020706@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35004 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934513Ab1JEP6M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 11:58:12 -0400
In-Reply-To: <4E8BE63F.4020706@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Oct 2011 22:08:15 -0700
Sridhar Samudrala <sri@us.ibm.com> wrote:

>=20
> On Tue, 2011-10-04 at 16:00 -0700, Stephen Hemminger wrote:
> > On Tue, 04 Oct 2011 15:54:07 -0700
> > Sridhar Samudrala<sri@us.ibm.com  <mailto:sri@us.ibm.com>>  wrote:
> >
> > >  On Tue, 2011-10-04 at 15:42 -0700, Stephen Hemminger wrote:
> > >  >  On Wed, 5 Oct 2011 00:32:31 +0200
> > >  >  Micha=C5=82 Miros=C5=82aw<mirqus@gmail.com  <mailto:mirqus@gm=
ail.com>>  wrote:
> > >  >
> > >  >  >  2011/10/5 Sridhar Samudrala<sri@us.ibm.com  <mailto:sri@us=
=2Eibm.com>>:
> > >  >  >  >  On Tue, 2011-10-04 at 14:07 -0700, Stephen Hemminger wr=
ote:
> > >  >  >  >>  On Tue, 04 Oct 2011 09:58:55 -0700
> > >  >  >  >>  Andi Kleen<andi@firstfloor.org  <mailto:andi@firstfloo=
r.org>>  wrote:
> > >  >  >  >>  >  Stephen Hemminger<shemminger@vyatta.com  <mailto:sh=
emminger@vyatta.com>>  writes:
> > >  >  >  >>  >  >  This adds a new 'br' command which is the bridgi=
ng equivalent of
> > >  >  >  >>  >  >  the ip command. More of a demo of how to use net=
link and bridging
> > >  >  >  >>  >  >  at this point.
> > >  >  >  >>  >  Please name it "bridge", not "br"
> > >  >  >  >>  Ok, but it breaks the existing pattern.
> > >  >  >  >  Is this supposed to replace brctl utility?
> > >  >  >  >
> > >  >  >  >  Can we add/delete a bridge and add/delete interfaces to=
 a bridge using
> > >  >  >  >  this command?
> > >  >  >  >
> > >  >  >  >  If so, why not make it
> > >  >  >  >    ip bridge add/del<brname>
> > >  >  >  >    ip bridge addif/delif<brname>  <ifname>
> > >  >  >
> > >  >  >  I'll add one more idea:
> > >  >  >
> > >  >  >  ip link add/del<brname>  type bridge
> > >  >  >  ip bridge add/del<brname>  <ifname>
> > >  >  >  ip bridge fdb ...
> > >  >
> > >  >  In 3.0 you can already do:
> > >  >  # ip link add dev br3 type bridge
> This is a new syntax that i think works only for 'bridge' type.


The bridge interface to 'ip link' is nothing special. The same syntax
is available for macvlan, vlan, and bonding.


> All other types require a prefix 'ip link add link'



=46or vlan:
  ip link add link eth0 name eth0.1 type vlan id 1

The reason there is no 'link' parameter when creating a bridge is that
the bridge is a standalone device it is not slaved to an underlying
device.

>=20
> I think the ip command help text should be updated to include this sy=
ntax.


patches accepted...

>=20
> > >  >  # ip link set dev eth3 master br3
>=20
> looks like the command to delete an interface from a bridge is
>        ip link set dev eth3 nomaster
>=20
> Somehow this interface doesn't look all that intuitive.

Propose something better.=20


> Currently we have 'ip route' and 'ip neigh' to manipulate routing and
> neighbor entry tables. I think 'ip bridge' would be good way to exten=
d
> this to support bridging.
>=20
> If it is not too late, can we have a interface where all bridge relat=
ed
> commands can be done using the same prefix.
>=20
> I think we also should think about how this syntax can be extended to=
 show
> embedded bridges in SR-IOV NICs.

The iproute2 commands in general try to be as close to the
underlying netlink protocol. This makes it less user friendly but small=
er,
easier to program. The only part of bridging that is special is the
forwarding database which is similar to the neighbor table.
If I do merge bridging into ip, it would not be as 'ip bridge' but as
another protocol family.

   ip -family bridge neigh ...


As far as SR-IOV, the interface in the kernel is netlink and the hardwa=
re
people are free to use netlink to use the same messages for SR-IOV, but
haven't.



 =20
