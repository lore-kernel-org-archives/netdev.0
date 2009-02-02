From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Mon, 02 Feb 2009 21:29:30 +0100
Message-ID: <498757AA.8010101@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org> <loom.20090202T194942-55@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Wes Chow <wchow@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49266 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbZBBU3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 15:29:39 -0500
In-Reply-To: <loom.20090202T194942-55@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wes Chow a =E9crit :
>=20
> (I'm Kenny's colleague, and I've been doing the kernel builds)
>=20
> First I'd like to note that there were a lot of bnx2 NAPI changes bet=
ween=20
> 2.6.21 and 2.6.22. As a reminder, 2.6.21 shows tiny amounts of packet=
 loss,
> whereas loss in 2.6.22 is significant.
>=20
> Second, some CPU affinity info: if I do like Eric and pin all of the
> apps onto a single CPU, I see no packet loss. Also, I do *not* see
> ksoftirqd show up on top at all!
>=20
> If I pin half the processes on one CPU and the other half on another =
CPU, one=20
> ksoftirqd processes shows up in top and completely pegs one CPU. My p=
acket loss
> in that case is significant (25%).
>=20
> Now, the strange case: if I pin 3 processes to one CPU and 1 process =
to=20
> another, I get about 25% packet loss and ksoftirqd pins one CPU. Howe=
ver, one
> of the apps takes significantly less CPU than the others, and all app=
s lose the
> *exact same number of packets*. In all other situations where we see =
packet
> loss, the actual number lost per application instance appears random.

You see same number of packet lost because they are lost at NIC level

(check ifconfig eth0 for droped packets)

if softirq is too busy to process packets, we are not able to get them
from hardware in time.

>=20
> We're about to plug in an Intel ethernet card into this machine to co=
llect more=20
> rigorous testing data. Please note, though, that we have seen packet =
loss with
> a tg3 chipset as well. For now, though, I'm assuming that this is pur=
ely a bnx2
> problem.
>=20
> If I understand correctly, when the nic signals a hardware interrupt,=
 the=20
> kernel grabs it and defers the meaty work to the softirq handler -- h=
ow does it
> decide which ksoftirqd gets the interrupts? Is this something determi=
ned by how
> the driver implements the NAPI?


Normaly, softirq runs on same cpu (the one handling hard irq)

