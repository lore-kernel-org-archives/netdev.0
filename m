From: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Subject: Re: ixgbe RSS not working as expected with 8021q and bridging
Date: Tue, 15 Dec 2009 10:21:19 -0700
Message-ID: <20091215172119.GF20231@esk.cs.usu.edu>
References: <20091210231103.GA20231@esk.cs.usu.edu>
 <4B218E36.4030808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esk.cs.usu.edu ([129.123.28.15]:50069 "EHLO esk.cs.usu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754636AbZLORVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 12:21:20 -0500
Content-Disposition: inline
In-Reply-To: <4B218E36.4030808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  Dec 11  1:11+0100, Eric Dumazet wrote:
> Le 11/12/2009 00:11, Eldon Koyle a =E9crit :
> > We have built a firewall with two 10 Gbit interfaces (intel 82598EB=
) and
> > are doing some testing.  A simple bridge between the two interfaces=
 acts
> > as expected with packets being distributed fairly evenly across all=
 of
> > the rx/tx queues.
> >=20
> > We then switched to tagged vlans on both interfaces (10 vlans each,=
 8
> > source and 8 dest addresses per vlan) and bridged eth0.N to eth1.N,=
 and
> > many of our queues (and CPUs) remained idle, and all of our VLAN tr=
affic
> > went out on the same tx queue.  Are multiple transmit queues suppor=
ted
> > with 802.1q?  How do we figure out what is causing some of our rece=
ive
> > queues to be unused?
> >=20
> > We are using 2.6.31 (from Debian) and ixgbe-2.0.44.14 .
> >=20
>=20
> You need more recent kernel (2.6.32) to get multi queue support on vl=
ans, sorry.

Excellent.  2.6.32 solved half of the problem.  Now, we are using the
same number of rx and tx queues.  We are still seeing no packets on 3 o=
f
our 8 rx queues on each interface, though (no packets on 2, 4 or 6).
Does the card assign queues in hardware, or is that handled by the
kernel?

--=20
Eldon Koyle
