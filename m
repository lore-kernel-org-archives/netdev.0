From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Multicast socket option
Date: Fri, 29 May 2009 07:21:21 -0700
Message-ID: <4A1FEF61.9090005@us.ibm.com>
References: <4A1EC33E.1080201@us.ibm.com> <200905290925.19155.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Christoph Lameter <cl@linux.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36901 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757892AbZE2OVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 10:21:36 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4TEI5ID017280
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 08:18:05 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4TELPS1232454
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 08:21:36 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4TELL2M004146
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 08:21:22 -0600
In-Reply-To: <200905290925.19155.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=E9mi Denis-Courmont wrote:

>> In this case, default behaviour is _unchanged_ from the current
>> Linux standard. The socket option is set by default to provide
>> original behaviour. Sockets wishing to receive data only from
>> multicast groups they join explicitly will need to clear this
>> socket option.
>=20
> You can already achieve this by checking the destination address in t=
he=20
> SOL_PKTINFO ancilliary data. Sure, it will cause extra context switch=
es to=20
> process unwanted packets but it will work with any kernel version.
>=20

True, and depending on your environment and workload, this
is a non-event or a big deal. For low latency, real time
and other performance-sensitive applications, this can be
an issue. Think lots (hundreds of threads, perhaps) listening
on different channels(groups). They will likely all get
woken, scheduled, possibly preempt running lower-priority
tasks to process this delivery that they don't need. Seen
across the system, the delivery by the kernel of packets
to user space processes which don't want them can be very
significant overhead (context switches, scheduling out/in,...).

thanks,
Nivedita



