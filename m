From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: igb + balance-rr + bridge + IPv6 = no go without promiscuous mode
Date: Wed, 4 Jan 2012 13:10:08 -0500
Message-ID: <20120104181008.GA24324@hmsreliant.think-freely.org>
References: <4EF44CEE.5020704@bootc.net>
 <CAADHFRBWR0JJNmPzQA3=40s5a6fZ3TJEoC0aWzo+3wXruEZC5A@mail.gmail.com>
 <4EF454C7.8020305@bootc.net>
 <4EF45C7D.8090409@gmail.com>
 <4EF45E79.6020803@bootc.net>
 <4EFA3E3C.4020706@bootc.net>
 <9BBC4E0CF881AA4299206E2E1412B62602B194@ORSMSX102.amr.corp.intel.com>
 <9BBC4E0CF881AA4299206E2E1412B62602BB18@ORSMSX102.amr.corp.intel.com>
 <4F048534.5010803@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Chris Boot <bootc@bootc.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56160 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558Ab2ADSKV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 13:10:21 -0500
Content-Disposition: inline
In-Reply-To: <4F048534.5010803@bootc.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2012 at 04:58:28PM +0000, Chris Boot wrote:
> On 04/01/2012 16:00, Wyborny, Carolyn wrote:
> >
> >
> >>-----Original Message-----
> >>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel=
=2Eorg]
> >>On Behalf Of Wyborny, Carolyn
> >>Sent: Tuesday, January 03, 2012 3:24 PM
> >>To: Chris Boot; Nicolas de Peslo=C3=BCan
> >>Cc: netdev; e1000-devel@lists.sourceforge.net
> >>Subject: RE: igb + balance-rr + bridge + IPv6 =3D no go without
> >>promiscuous mode
> >>
> >>
> >>
> >>>-----Original Message-----
> >>>From: netdev-owner@vger.kernel.org [mailto:netdev-
> >>owner@vger.kernel.org]
> >>>On Behalf Of Chris Boot
> >>>Sent: Tuesday, December 27, 2011 1:53 PM
> >>>To: Nicolas de Peslo=C3=BCan
> >>>Cc: netdev
> >>>Subject: Re: igb + balance-rr + bridge + IPv6 =3D no go without
> >>>promiscuous mode
> >>>
> >>>On 23/12/2011 10:56, Chris Boot wrote:
> >>>>On 23/12/2011 10:48, Nicolas de Peslo=C3=BCan wrote:
> >>>>>[ Forwarded to netdev, because two previous e-mail erroneously s=
ent
> >>>in
> >>>>>HTML ]
> >>>>>
> >>>>>Le 23/12/2011 11:15, Chris Boot a =C3=A9crit :
> >>>>>>On 23/12/2011 09:52, Nicolas de Peslo=C3=BCan wrote:
> >>>>>>>
> >>>>>>>
> >>>>>>>Le 23 d=C3=A9c. 2011 10:42, "Chris Boot"<bootc@bootc.net
> >>>>>>><mailto:bootc@bootc.net>>  a =C3=A9crit :
> >>>>>>>>
> >>>>>>>>Hi folks,
> >>>>>>>>
> >>>>>>>>As per Eric Dumazet and Dave Miller, I'm opening up a separat=
e
> >>>>>>>thread on this issue.
> >>>>>>>>
> >>>>>>>>I have two identical servers in a cluster for running KVM
> >>virtual
> >>>>>>>machines. They each have a
> >>>>>>>single connection to the Internet (irrelevant for this) and tw=
o
> >>>>>>>gigabit connections between each
> >>>>>>>other for cluster replication, etc... These two connections ar=
e in
> >>>a
> >>>>>>>balance-rr bonded connection,
> >>>>>>>which is itself member of a bridge that the VMs attach to. I'm
> >>>>>>>running v3.2-rc6-140-gb9e26df on
> >>>>>>>Debian Wheezy.
> >>>>>>>>
> >>>>>>>>When the bridge is brought up, IPv4 works fine but IPv6 does
> >>not.
> >>>>>>>I can use neither the
> >>>>>>>automatic link-local on the brid ge nor the static global addr=
ess
> >>I
> >>>>>>>assign. Neither machine can
> >>>>>>>perform neighbour discovery over the link until I put the bond
> >>>>>>>members (eth0 and eth1) into
> >>>>>>>promiscuous mode. I can do this either with tcpdump or 'ip lin=
k
> >>set
> >>>>>>>dev ethX promisc on' and this
> >>>>>>>is enough to make the link spring to life.
> >>>>>>>
> >>>>>>>For as far as I remember, setting bond0 to promisc should set =
the
> >>>>>>>bonding member to promisc too.
> >>>>>>>And inserting bond0 into br0 should set bond0 to promisc... So
> >>>>>>>everything should be in promisc
> >>>>>>>mode anyway... but you shoudn't have to do it by hand.
> >>>>>>>
> >>>>>>
> >>>>>>Sorry, I should have added that I tried this. Setting bond0 or =
br0
> >>>to
> >>>>>>promisc has no effect. I
> >>>>>>discovered this by running tcpdump on br0 first, then bond0, th=
en
> >>>>>>eventually each bond member in
> >>>>>>turn. Only at the last stage did things jump to life.
> >>>>>>
> >>>>>>>>
> >>>>>>>>This cluster is not currently live so I can easily test patch=
es
> >>>>>>>and various configurations.
> >>>>>>>
> >>>>>>>Can you try to remove the bonding part, connecting eth0 and et=
h1
> >>>>>>>directly to br0 and see if it
> >>>>>>>works better? (This is a test ony. I perfectly understand that=
 you
> >>>>>>>would loose balance-rr in this
> >>>>>>>setup.)
> >>>>>>>
> >>>>>>
> >>>>>>Good call. Let's see.
> >>>>>>
> >>>>>>I took br0 and bond0 apart, took eth0 and eth1 out of enforced
> >>>>>>promisc mode, then manually built a
> >>>>>>br0 with eth0 in only so I didn't cause a network loop. Adding =
eth0
> >>>>>>to br0 did not make it go into
> >>>>>>promisc mode, but IPv6 does work over this setup. I also made s=
ure
> >>>ip
> >>>>>>-6 neigh was empty on both
> >>>>>>machines before I started.
> >>>>>>
> >>>>>>I then decided to try the test with just the bond0 in balance-r=
r
> >>>>>>mode. Once again I took everything
> >>>>>>down and ensured no promisc mode and no ip -6 neigh. I noticed
> >>bond0
> >>>>>>wasn't getting a link-local and
> >>>>>>I found out for some reason
> >>>>>>/proc/sys/net/ipv6/conf/bond0/disable_ipv6 was set on both serv=
ers
> >>>so I
> >>>>>>set it to 0. That brought things to life.
> >>>>>>
> >>>>>>So then I put it all back together again and it didn't work. I =
once
> >>>>>>again noticed disable_ipv6 was
> >>>>>>set on the bond0 interfaces, now part of the bridge. Toggling t=
his
> >>>on
> >>>>>>the _bond_ interface made
> >>>>>>things work again.
> >>>>>>
> >>>>>>What's setting disable_ipv6? Should this be having an impact if=
 the
> >>>>>>port is part of a bridge?
> >>>>
> >>>>Hmm, as a further update... I brought up my VMs on the bridge wit=
h
> >>>>disable_ipv6 turned off. The VMs on one host couldn't see what wa=
s on
> >>>>the other side of the bridge (on the other server) until I turned
> >>>>promisc back on manually. So it's not entirely disable_ipv6's fau=
lt.
> >>>
> >>>Hi,
> >>>
> >>>I don't want this to get lost around the Christmas break, so I'm j=
ust
> >>>resending it. I'm still seeing the same behaviour as before.
> >>>
> >>> From above:
> >>>
> >>>>>>>For as far as I remember, setting bond0 to promisc should set =
the
> >>>>>>>bonding member to promisc too.
> >>>>>>>And inserting bond0 into br0 should set bond0 to promisc... So
> >>>>>>>everything should be in promisc
> >>>>>>>mode anyway... but you shoudn't have to do it by hand.
> >>>
> >>>This definitely doesn't happen, at least according to 'ip link sho=
w |
> >>>grep PROMISC'.
> >>>
> >>>Chris
> >>>
> >>>--
> >>>Chris Boot
> >>>bootc@bootc.net
> >>>--
> >>>To unsubscribe from this list: send the line "unsubscribe netdev" =
in
> >>>the body of a message to majordomo@vger.kernel.org
> >>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >>Sorry for the delay in responding.  I'm not sure what is going on h=
ere
> >>and I'm not our bonding expert who is still out on holidays.  Howev=
er,
> >>we'll try to reproduce this.  When I get some more advice, I may be
> >>asking for some more data.
> >>
> >>Thanks,
> >>
> >>Carolyn
> >>Carolyn Wyborny
> >>Linux Development
> >>LAN Access Division
> >>Intel Corporation
> >>N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*
> >>jg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=
=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=
=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=
=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=
=BD=D9=A5
> >
> >Hello,
> >
> >Check your ip_forward configuration on your bridge to make sure its =
configured to forward ipv6 packets and also please send the contents of=
 /etc/modprobe.d/bonding.conf and the contents of your routing table an=
d we'll continue to work on this.
>=20
> Hi Carolyn,
>=20
> Surely ip_forward only needs to be set if I'm wanting to _route_
> IPv6 rather than simply have them go through a bridge untouched? I
> don't want the host to route IPv6 at all. Setting this also has the
> unintended effect of disabling SLAAC which I wish to keep enabled.
>=20
> I don't have a /etc/modprobe.d/bonding.conf; I'm using Debian and
> configuring my bonding and bridging using the configuration I pasted
> in my original email. Here it is again:
>=20
> >iface bond0 inet manual
> >        slaves eth0 eth1
> >        bond-mode balance-rr
> >        bond-miimon 100
> >        bond-downdelay 200
> >        bond-updelay 200
> >
> >iface br0 inet static
> >        address [snip]
> >        netmask 255.255.255.224
> >        bridge_ports bond0
> >        bridge_stp off
> >        bridge_fd 0
> >        bridge_maxwait 5
> >iface br0 inet6 static
> >        address [snip]
> >        netmask 64
>=20
> Despite the static IPv6 address I use SLAAC to grab a default gateway=
=2E
>=20
> My IPv6 routing table:
>=20
> 2001:8b0:49:200::/64 dev br0  proto kernel  metric 256  expires 25923=
17sec
> fe80::/64 dev br0  proto kernel  metric 256
> fe80::/64 dev bond1  proto kernel  metric 256
> fe80::/64 dev vnet0  proto kernel  metric 256
> fe80::/64 dev vnet1  proto kernel  metric 256
> fe80::/64 dev vnet2  proto kernel  metric 256
> fe80::/64 dev vnet3  proto kernel  metric 256
> fe80::/64 dev vnet4  proto kernel  metric 256
> default via fe80::5652:ff:fe16:15a0 dev br0  proto kernel  metric
> 1024 expires 1793sec
>=20
> HTH,
> Chris
>=20
> --=20
> Chris Boot
> bootc@bootc.net
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
Can you post the output of ip -6 addr show?  My first thought would be =
that
something in the bond is looping back ndisc frames and causing duplicat=
e address
detection to fail.  That will show up as the dadfailed flag in the addr=
 show
command.  If thats the case, we'd need to figure out why thats happenin=
g, but
you could likely work around it by setting
/proc/sys/net/ipv6/conf/<ifname>/accept_dad to 0 for the time being

Best
Neil
