From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Tue, 02 Dec 2014 14:12:10 -0300
Message-ID: <547DF2EA.2020908@free-electrons.com>
References: <20141202071304.GA22512@1wt.eu> <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>, Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:34180 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754139AbaLBROD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:14:03 -0500
In-Reply-To: <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

On 12/02/2014 09:18 AM, Eric Dumazet wrote:
[..]
>=20
> I am surprised TCP even worked correctly with this problem.
>=20
> I highly suggest BQL for this driver, now this issue is fixed.
>=20

Implementing BQL for the mvneta driver was something I wanted to do a
while ago, but you explained that these kind drivers (i.e. those with
software TSO) didn't need BQL, because the latency that resulted from
the ring was too small.

Quoting (http://www.spinics.net/lists/netdev/msg284439.html):
""
Note that a full size TSO packet (44 or 45 MSS) requires about 88 or 90
descriptors.

So I do not think BQL is really needed, because a 512 slots TX ring won=
t
add a big latency : About 5 ms max.

BQL is generally nice for NIC supporting hardware TSO, where a 64KB TSO
packet consumes 3 or 4 descriptors.

Also note that TCP Small Queues should limit TX ring occupancy of a
single bulk flow anyway.
""

Maybe I misunderstood something?
--=20
Ezequiel Garc=C3=ADa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
