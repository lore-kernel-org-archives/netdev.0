From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet Overrun for traffic over 1 Gbps
Date: Sat, 20 Jun 2009 14:11:35 +0200
Message-ID: <4A3CD1F7.5000904@gmail.com>
References: <e31d15d70906200252g300fda01rf227f54259c33b7c@mail.gmail.com> <e31d15d70906200254m3ab04065y3f4b853d0de72471@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Deepak Vishwakarma <vishwakarma.deepak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44869 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbZFTMLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 08:11:47 -0400
In-Reply-To: <e31d15d70906200254m3ab04065y3f4b853d0de72471@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Deepak Vishwakarma a =E9crit :
> Hi,
>=20
> I have a high end server machine(multi core and large memory space)
> with 10 Gbps NIC. With linux kernel 2.6.18 it is giving packet overru=
n
> as traffic goes beyond 1.5 Gbps. I need suggestions in tuning kernel
> so that it can handle higher traffic rates.
>=20
> I have a 10 Gbps test bed to test the capability of server, equipped
> with 10Gig switch and traffic is generated from many 1Gig machines. I
> have tested server machine by gradually increasing the incoming
> traffic rate and it's starting to do packet overrun as it crosses 1
> Gbps.
>=20
> The 10 Gig NIC is from broadcom,  (netxtreme). I have tested NIC with
> the driver shipped by vendor that is bnx2x v 1.44 and latest availabl=
e
> on net, both are giving more or less same result. Will it help to try
> latest kernel 2.6.30 ? or what could be other possible tuning in
> kernel to make it handle high traffic (3-4 Gbps).
>=20

This is quite difficult to generically answer to your question without
 more data from you about the workload, and your setup.
(kind of traffic, is it UDP, (unicast or multicast), TCP, number
of flows...)

One can easily stress a high end server with a moderate network
traffic, depending on the work done by receiver. I have some
workloads that saturate the cpu handling RX queue, even way before
1 Gbps level, because this cpu has to wakeup tasks at high rate.

With small application changes, it is also possible to reduce
number of wakeups done by the receiver cpu, giving more cpu
cycles to network stack.

One possible way to get high traffic, even with fast cpus/cores,
is to use a NIC that is able to split the load into multiple RX/TX queu=
es,
so that several cpus can work together and process data concurrently.

One important thing is to make sure NIC interrupts for a given
RX queue are serviced by only one CPU, to avoid cache line ping
pongs between cpus. You can double the traffic with
proper irq affinities.

Many scalability improvements were done in network stack between
 2.6.18 and 2.6.30, so you should try a recent kernel.

Multi queue management definitly improved a lot during last releases.
