From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Intel 82598, RSS and PPPoE
Date: Thu, 28 Jan 2010 11:32:42 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001281127430.360@jbrandeb-desk1.amr.corp.intel.com>
References: <201001281334.51123.alex@wildpark.net> <1264694357.2930.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Lapidus <alex@wildpark.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40719 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320Ab0A1Tco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 14:32:44 -0500
In-Reply-To: <1264694357.2930.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 28 Jan 2010, Eric Dumazet wrote:

> Le jeudi 28 janvier 2010 =C3=A0 13:34 +0200, Alexander Lapidus a =C3=A9=
crit :
> > Hello, everybody!
> >  Help is needed in such case. We have a linux-box, running under Ce=
ntOS 5.4=20
> > with a latest kernel. Intel 10 Gigabit AF DA Dual Port Server Adapt=
er (based=20
> > on Intel 82598EB) is used for routing purposes. Linux-box is dual C=
PU Xeon=20
> > E5530 server.  Interface eth0 is an uplink to the network core with=
 pure IPv4=20
> > trafic on it. Interface eth1 is an downlink to customers. We have 3=
000 802.1q=20
> > VLANs on it. PPPoE server daemon is running on all VLAN interfaces.=
 So we have=20
> > ethernet frames with 802.1q VLAN tag and PPPoE header incapsulated.=
 Our=20
> > problem is with RX packet distribution between rx-queues on this  i=
nterface.=20
> > All those packets are coming to RX-queue-0. As i understood from In=
tel=20
> > specification on 82598 chipset, problem is with RSS, which can't de=
code PPPoE=20
> > header, so packet is going only to queue 0. My question is how to f=
orce such=20
> > packets to spread between different queues. May be it's possible to=
 use VMDq=20
> > in this configuration, or any other solution?
> >=20
> > P.S. We tried this configuration with in-kernel driver and with lat=
est driver=20
> > from Intel (ixgbe-2.0.44.14). Situation is the same.
> >=20
> >=20
>=20
> What exact linux kernel version are you using ?
>=20
> If hardware is not able to spread packets into multiple receive queue=
s
> because of VLAN or PPOE encapsulation then you might try RPS (not yet
> included in kernel) and add appropriate
> PPOE decoding in low level frame handling.
>=20
> RPS v5 pointer : http://www.spinics.net/lists/netdev/msg118378.html

In addition or instead of RPS, using the 82598 software developers manu=
al=20
you could pretty quickly code up a queue spreading model using the vlan=
=20
tags and VMDq mode.  I believe you can just turn on VMDq mode and get t=
he=20
vlan filtering behavior enabled with a single register write.

It appears the VFTA table has some entries in it that can control the=20
queue picked for each VLAN id hash match in the table.  I think even=20
filling this with an incrementing value would allow vlan packets with=20
non-IP traffic to be automatically spread out to all available queues (=
as=20
long as there was enough randomness in the hash result for the input vl=
an=20
ids.

Hope this helps, you might want to consider sending queries like this i=
n=20
the future to e1000-devel@lists.sourceforge.net

Jesse
